import '../models/arquivo_escolhido.dart';
import '../models/versao_app.dart';
import '../repositories/arquivo_repository.dart';
import '../repositories/config_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

/// Número do administrador e versão do app: valem para todos os logins,
/// por isso este provider fica no topo do app (main.dart).
class AppInfoProvider extends SafeNotifier {
  AppInfoProvider(this._repo, this._arquivos);

  final ConfigRepository _repo;
  final ArquivoRepository _arquivos;
  static const _limite = 50 * 1024 * 1024;

  String? telefone;
  VersaoApp? ultima;
  String instalada = '';
  bool carregando = false;
  String? erro;

  bool get temNova {
    final u = ultima;
    return u != null &&
        instalada.isNotEmpty &&
        VersaoApp.comparar(u.versao, instalada) > 0;
  }

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      instalada = await _repo.versaoInstalada();
      telefone = await _repo.telefoneAdmin();
      ultima = await _repo.ultimaVersao();
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<String?> _acao(Future<void> Function() f) async {
    try {
      await f();
      await carregar();
      return null;
    } catch (e) {
      return mensagemDeErro(e);
    }
  }

  Future<String?> salvarTelefone(String t) =>
      _acao(() => _repo.salvarTelefoneAdmin(t.trim()));

  Future<(ArquivoEscolhido?, String?)> escolherArquivo() async {
    try {
      final a = await _arquivos.escolher();
      if (a != null && a.bytes.length > _limite) {
        return (null, 'O arquivo passa de 50 MB, o limite do plano grátis.');
      }
      return (a, null);
    } catch (e) {
      return (null, mensagemDeErro(e));
    }
  }

  Future<String?> publicarVersao(
          ArquivoEscolhido a, String versao, String? notas) =>
      _acao(() => _repo.publicarVersao(a, versao, notas));
}
