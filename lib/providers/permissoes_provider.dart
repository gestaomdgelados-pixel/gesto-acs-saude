import '../repositories/arquivo_repository.dart';
import '../repositories/permissoes_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class PermissoesProvider extends SafeNotifier {
  PermissoesProvider(this._repo, this._arquivos);

  final PermissoesRepository _repo;
  final ArquivoRepository _arquivos;

  bool? internet;
  bool? notificacoes;
  bool? arquivos;
  bool ocupado = false;
  String? erro;

  Future<void> _rodar(Future<void> Function() f) async {
    ocupado = true;
    erro = null;
    notifyListeners();
    try {
      await f();
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      ocupado = false;
      notifyListeners();
    }
  }

  Future<void> _testarInternet() async {
    try {
      await _repo.testarInternet();
      internet = true;
    } catch (e) {
      internet = false;
      rethrow;
    }
  }

  Future<void> verificar() => _rodar(() async {
        notificacoes = await _repo.notificacoes();
        await _testarInternet();
      });

  Future<void> verificarInternet() => _rodar(_testarInternet);

  Future<void> pedirNotificacoes() => _rodar(() async {
        notificacoes = await _repo.pedirNotificacoes();
      });

  /// O sistema libera o acesso a cada arquivo escolhido pela pessoa.
  Future<void> autorizarArquivos() => _rodar(() async {
        final a = await _arquivos.escolher();
        if (a != null) arquivos = true;
      });
}
