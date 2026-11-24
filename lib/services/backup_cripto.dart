import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../repositories/app_exception.dart';

/// Tranca e abre o arquivo de backup com AES-256-GCM e chave derivada da senha.
class BackupCripto {
  static const _marca = 'gestao-acs-backup';

  final _aes = AesGcm.with256bits();
  final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256);

  Future<SecretKey> _chave(String senha, List<int> sal) =>
      _kdf.deriveKeyFromPassword(password: senha, nonce: sal);

  Future<Uint8List> trancar(Map<String, dynamic> dados, String senha) async {
    final sal = SecretKeyData.random(length: 16).bytes;
    final caixa = await _aes.encrypt(
      utf8.encode(jsonEncode(dados)),
      secretKey: await _chave(senha, sal),
    );
    final arquivo = {
      'formato': _marca,
      'versao': 1,
      'sal': base64Encode(sal),
      'nonce': base64Encode(caixa.nonce),
      'mac': base64Encode(caixa.mac.bytes),
      'dados': base64Encode(caixa.cipherText),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(arquivo)));
  }

  Future<Map<String, dynamic>> abrir(Uint8List bytes, String senha) async {
    final Map<String, dynamic> arq;
    final SecretBox caixa;
    final List<int> sal;
    try {
      arq = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (arq['formato'] != _marca) throw const FormatException();
      sal = base64Decode(arq['sal'] as String);
      caixa = SecretBox(
        base64Decode(arq['dados'] as String),
        nonce: base64Decode(arq['nonce'] as String),
        mac: Mac(base64Decode(arq['mac'] as String)),
      );
    } catch (_) {
      throw const AppException(
          'Este arquivo não é um backup do Gestão ACS Saúde.');
    }
    try {
      final claro = await _aes.decrypt(caixa, secretKey: await _chave(senha, sal));
      return jsonDecode(utf8.decode(claro)) as Map<String, dynamic>;
    } on SecretBoxAuthenticationError {
      throw const AppException('Senha incorreta ou arquivo danificado.');
    }
  }
}
