import '../models/vacina.dart';
import '../repositories/vacina_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class VacinasProvider extends SafeNotifier {
  VacinasProvider(this._repo);

  final VacinaRepository _repo;
  List<VacinaTipo> tipos = [];
  List<VacinaRegistro> registros = [];
  bool carregando = false;
  String? erro;
  Map<String, VacinaRegistro> _porChave = {};

  static String _chave(String membroId, String tipoId) => '$membroId|$tipoId';

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      tipos = await _repo.listarTipos();
      registros = await _repo.listarRegistros();
      _porChave = {for (final r in registros) _chave(r.membroId, r.tipoId): r};
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  /// Todas as vacinas do catálogo para a pessoa, com o registro quando existe.
  List<VacinaItem> itensDe(String membroId) => [
        for (final t in tipos) VacinaItem(t, _porChave[_chave(membroId, t.id)]),
      ];

  List<VacinaRegistro> proximasAgendadas(int quantidade) {
    final lista = registros
        .where((r) => r.status == StatusVacina.agendada && r.dataPrevista != null)
        .toList()
      ..sort((a, b) => a.dataPrevista!.compareTo(b.dataPrevista!));
    return lista.take(quantidade).toList();
  }

  String nomeDoTipo(String id) {
    for (final t in tipos) {
      if (t.id == id) return t.nome;
    }
    return 'Vacina removida';
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

  Future<String?> criarTipo(String nome, String? descricao) =>
      _acao(() => _repo.criarTipo(nome, descricao));

  Future<String?> excluirTipo(VacinaTipo t) => _acao(() => _repo.excluirTipo(t.id));

  Future<String?> agendar(String membroId, String tipoId, DateTime data) =>
      _acao(() => _repo.agendar(membroId, tipoId, data));

  Future<String?> concluir(String membroId, String tipoId, DateTime data,
          String aplicadoPor, String lote) =>
      _acao(() => _repo.concluir(membroId, tipoId,
          aplicadaEm: data, aplicadoPor: aplicadoPor, lote: lote));

  Future<String?> excluirRegistro(String id) =>
      _acao(() => _repo.excluirRegistro(id));
}
