import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/arquivo_escolhido.dart';
import 'app_exception.dart';

class ArquivoRepository {
  /// Retorna null quando a pessoa cancela. [extensoes] limita os tipos (ex.: pdf).
  Future<ArquivoEscolhido?> escolher({List<String>? extensoes}) async {
    final arquivos = await FilePicker.pickFiles(
      type: extensoes == null ? FileType.any : FileType.custom,
      allowedExtensions: extensoes,
    );
    if (arquivos.isEmpty) return null;
    final a = arquivos.first;
    try {
      return ArquivoEscolhido(await a.readAsBytes(), a.name);
    } catch (_) {
      throw const AppException('Não foi possível ler o arquivo escolhido.');
    }
  }

  /// Retorna false quando a pessoa cancela a escolha do local.
  Future<bool> salvar(String nome, Uint8List bytes) async {
    final uri = await FilePicker.saveFile(fileName: nome, bytes: bytes);
    // No navegador o arquivo é baixado direto e não há caminho de retorno.
    return kIsWeb || uri != null;
  }

  /// Retorna null quando a pessoa cancela a escolha do arquivo.
  Future<Uint8List?> abrir() async {
    final arquivos = await FilePicker.pickFiles(type: FileType.any);
    if (arquivos.isEmpty) return null;
    try {
      return await arquivos.first.readAsBytes();
    } catch (_) {
      throw const AppException('Não foi possível ler o arquivo escolhido.');
    }
  }
}
