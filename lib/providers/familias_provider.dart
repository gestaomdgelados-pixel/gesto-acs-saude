import '../models/familia.dart';
import '../models/membro.dart';
import '../repositories/familia_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class FamiliasProvider extends SafeNotifier {
  FamiliasProvider(this._repo);

  final FamiliaRepository _repo;
  List<Familia> familias = [];
  List<Membro> membros = [];
  bool carregando = false;
  String? erro;

  List<Membro> membrosDe(String familiaId) =>
      membros.where((m) => m.familiaId == familiaId).toList();

  Familia? familiaPorId(String id) {
    for (final f in familias) {
      if (f.id == id) return f;
    }
    return null;
  }

  Membro? membroPorId(String id) {
    for (final m in membros) {
      if (m.id == id) return m;
    }
    return null;
  }

  String nomeDaFamilia(String id) => familiaPorId(id)?.responsavel ?? 'Família removida';

  String nomeDoMembro(String id) => membroPorId(id)?.nome ?? 'Pessoa removida';

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      familias = await _repo.listarFamilias();
      membros = await _repo.listarMembros();
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

  Future<String?> salvarFamilia(Familia f) => _acao(() => _repo.salvarFamilia(f));

  Future<String?> salvarMembro(Membro m) => _acao(() => _repo.salvarMembro(m));

  Future<String?> excluirMembro(Membro m) =>
      _acao(() => _repo.excluirMembro(m.id));
}
