import '../models/solicitacao.dart';
import '../repositories/solicitacao_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class SolicitacoesProvider extends SafeNotifier {
  /// Com [agenteId], mostra só as solicitações daquele agente.
  SolicitacoesProvider(this._repo, {this.agenteId});

  final SolicitacaoRepository _repo;
  final String? agenteId;

  List<Solicitacao> itens = [];
  bool carregando = false;
  String? erro;

  int get pendentes =>
      itens.where((s) => s.status == StatusSolicitacao.pendente).length;

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await _repo.listar(agenteId: agenteId);
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

  Future<String?> criar(SolicitacaoRascunho r) => _acao(() => _repo.criar(r));

  Future<String?> aceitar(Solicitacao s, DateTime quando) => _acao(() =>
      _repo.decidir(s.id, status: 'agendada', dataAgendada: quando));

  Future<String?> recusar(Solicitacao s, String motivo) =>
      _acao(() => _repo.decidir(s.id, status: 'recusada', motivo: motivo));
}
