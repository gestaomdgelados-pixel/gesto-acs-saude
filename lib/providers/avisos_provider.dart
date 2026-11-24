import '../models/aviso.dart';
import '../repositories/aviso_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class AvisosProvider extends SafeNotifier {
  AvisosProvider(this._repo);

  final AvisoRepository _repo;
  List<Aviso> itens = [];
  bool carregando = false;
  String? erro;

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await _repo.listar();
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

  Future<String?> criar(AvisoRascunho r) => _acao(() => _repo.criar(r));
  Future<String?> excluir(Aviso a) => _acao(() => _repo.excluir(a.id));
}
