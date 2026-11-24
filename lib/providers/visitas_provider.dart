import '../models/familia.dart';
import '../models/visita.dart';
import '../repositories/visita_repository.dart';
import '../services/relatorio_visitas_service.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class VisitasProvider extends SafeNotifier {
  VisitasProvider(this._repo, this._relatorio);

  final VisitaRepository _repo;
  final RelatorioVisitasService _relatorio;
  List<Visita> itens = [];
  bool carregando = false;
  String? erro;

  /// Os 12 meses anteriores ao mês atual (só meses já encerrados).
  static List<DateTime> mesesFechados(DateTime hoje) =>
      [for (var i = 1; i <= 12; i++) DateTime(hoje.year, hoje.month - i)];

  Visita? visitaPorId(String id) {
    for (final v in itens) {
      if (v.id == id) return v;
    }
    return null;
  }

  List<Visita> porStatus(StatusVisita status) {
    final lista = itens.where((v) => v.status == status).toList();
    lista.sort((a, b) => status == StatusVisita.agendada
        ? a.agendadaPara.compareTo(b.agendadaPara)
        : b.agendadaPara.compareTo(a.agendadaPara));
    return lista;
  }

  List<Visita> proximas(int quantidade) =>
      porStatus(StatusVisita.agendada).take(quantidade).toList();

  List<Visita> doMes(DateTime mes) {
    final lista = itens
        .where((v) =>
            v.agendadaPara.year == mes.year && v.agendadaPara.month == mes.month)
        .toList();
    lista.sort((a, b) => a.agendadaPara.compareTo(b.agendadaPara));
    return lista;
  }

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

  Future<String?> agendar(String familiaId, DateTime quando, String motivo) =>
      _acao(() => _repo.agendar(familiaId, quando, motivo));

  Future<String?> concluir(String id, Map<String, String> respostas) =>
      _acao(() => _repo.concluir(id, respostas));

  Future<String?> justificar(String id, String texto) =>
      _acao(() => _repo.justificar(id, texto));

  Future<String?> exportarRelatorio(
    DateTime mes, {
    required List<Familia> familias,
    required String agente,
  }) async {
    final agora = DateTime.now();
    final fechado = !DateTime(mes.year, mes.month + 1)
        .isAfter(DateTime(agora.year, agora.month));
    if (!fechado) {
      return 'O relatório só pode ser gerado para meses já encerrados.';
    }
    try {
      await _relatorio.compartilhar(
        mes: mes,
        visitas: doMes(mes),
        familias: familias,
        agente: agente,
      );
      return null;
    } catch (e) {
      return mensagemDeErro(e);
    }
  }
}
