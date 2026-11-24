import 'dart:typed_data';

import '../models/parse.dart';
import '../models/profile.dart';
import '../repositories/app_exception.dart';
import '../repositories/arquivo_repository.dart';
import '../repositories/backup_repository.dart';
import '../services/backup_cripto.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class BackupProvider extends SafeNotifier {
  BackupProvider(this._repo, this._cripto, this._arquivos);

  final BackupRepository _repo;
  final BackupCripto _cripto;
  final ArquivoRepository _arquivos;

  bool ocupado = false;
  String? erro;
  String? sucesso;

  void _inicio() {
    ocupado = true;
    erro = null;
    sucesso = null;
    notifyListeners();
  }

  Future<void> criar(Profile perfil, String senha) async {
    _inicio();
    try {
      final tabelas = await _repo.exportar(perfil.perfil, perfil.id);
      final bytes = await _cripto.trancar({
        'usuario_id': perfil.id,
        'login': perfil.usuario,
        'perfil': perfil.perfil.name,
        'criado_em': DateTime.now().toIso8601String(),
        'tabelas': tabelas,
      }, senha);
      final nome =
          'backup_${perfil.usuario}_${dataSql(DateTime.now())}.acsbackup';
      if (await _arquivos.salvar(nome, bytes)) {
        sucesso = 'Backup salvo no aparelho como "$nome".';
      } else {
        erro = 'O salvamento foi cancelado. Nenhum arquivo foi criado.';
      }
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      ocupado = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> escolherArquivo() async {
    try {
      return await _arquivos.abrir();
    } catch (e) {
      erro = mensagemDeErro(e);
      sucesso = null;
      notifyListeners();
      return null;
    }
  }

  Future<void> restaurar(Profile perfil, Uint8List bytes, String senha) async {
    _inicio();
    try {
      final dados = await _cripto.abrir(bytes, senha);
      if (dados['usuario_id'] != perfil.id) {
        throw AppException('Este backup pertence a outro login '
            '(${dados['login']}). Entre com esse login para usá-lo.');
      }
      final tabelas = (dados['tabelas'] as Map?)?.cast<String, dynamic>() ?? {};
      final n = await _repo.restaurar(perfil.perfil, perfil.id, tabelas);
      sucesso = n == 0
          ? 'Backup lido com sucesso. Tudo o que está nele já está no app.'
          : 'Backup aplicado: $n registro(s) recuperado(s).';
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      ocupado = false;
      notifyListeners();
    }
  }
}
