import '../models/log_entry.dart';
import '../models/profile.dart';
import '../repositories/admin_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class AdminProvider extends SafeNotifier {
  AdminProvider(this._repo);

  final AdminRepository _repo;
  List<Profile> usuarios = [];
  List<LogEntry> logs = [];
  bool carregando = false;
  String? erro;
  String? erroLogs;

  List<Profile> get agentes =>
      usuarios.where((u) => u.perfil == Perfil.agente && u.ativo).toList();

  String nomeDe(String? id) {
    for (final u in usuarios) {
      if (u.id == id) return u.nome;
    }
    return 'Sistema';
  }

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    erroLogs = null;
    notifyListeners();
    try {
      usuarios = await _repo.listarUsuarios();
    } catch (e) {
      erro = mensagemDeErro(e);
    }
    try {
      logs = await _repo.listarLogs();
    } catch (e) {
      erroLogs = mensagemDeErro(e);
    }
    carregando = false;
    notifyListeners();
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

  Future<String?> criar(LoginDados d) => _acao(() => _repo.criar(d));
  Future<String?> editar(Profile p, LoginDados d) =>
      _acao(() => _repo.editar(p.id, d));
  Future<String?> trocarSenha(Profile p, String senha) =>
      _acao(() => _repo.trocarSenha(p.id, senha));
  Future<String?> excluir(Profile p) => _acao(() => _repo.excluir(p.id));
}
