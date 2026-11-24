import '../models/aviso.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class StoriesProvider extends SafeNotifier {
  StoriesProvider(this._repo, {this.incluirInativos = false});

  final StoryRepository _repo;
  final bool incluirInativos;

  List<Story> itens = [];
  Set<String> vistos = {};
  bool carregando = false;
  String? erro;
  String? erroVistos;

  List<Story> get ativos => itens.where((s) => s.ativo && !s.expirada).toList();

  bool foiVisto(Story s) => vistos.contains(s.id);

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await _repo.listar(incluirInativos: incluirInativos);
    } catch (e) {
      erro = mensagemDeErro(e);
    }
    try {
      vistos = await _repo.vistos();
      erroVistos = null;
    } catch (e) {
      erroVistos = 'Não foi possível ler os status já vistos: ${mensagemDeErro(e)}';
    }
    carregando = false;
    notifyListeners();
  }

  Future<void> marcarVisto(Story s) async {
    if (vistos.contains(s.id)) return;
    vistos = {...vistos, s.id};
    notifyListeners();
    try {
      await _repo.marcarVisto(s.id);
    } catch (e) {
      erroVistos = 'Não foi possível marcar o status como visto: ${mensagemDeErro(e)}';
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

  Future<String?> publicarMidia(PropagandaRascunho r) =>
      _acao(() => _repo.publicarMidia(r));

  Future<String?> publicarCampanha(AvisoRascunho r) =>
      _acao(() => _repo.publicarCampanha(r));

  Future<String?> alterarAtivo(Story s, bool ativo) =>
      _acao(() => _repo.alterarAtivo(s.id, ativo));

  Future<String?> excluir(Story s) => _acao(() => _repo.excluir(s.id));
}
