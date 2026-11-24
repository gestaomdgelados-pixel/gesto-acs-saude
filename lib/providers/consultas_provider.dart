import '../models/consulta.dart';
import '../repositories/consulta_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class ConsultasProvider extends SafeNotifier {
  ConsultasProvider(this._repo, this.modo);

  final ConsultaRepository _repo;
  final ModoConsultas modo;

  List<Consulta> itens = [];
  List<OpcaoPessoa> agentes = [];
  bool carregando = false;
  String? erro;

  String get _agora => DateTime.now().toUtc().toIso8601String();

  List<Consulta> doStatus(StatusConsulta s) =>
      itens.where((c) => c.status == s).toList();

  String nomeAgente(String id) {
    for (final a in agentes) {
      if (a.id == id) return a.nome;
    }
    return 'Agente de saúde';
  }

  /// A consulta chegou para mim (agente que recebe do morador, ou gestão).
  bool _souDestino(Consulta c) {
    final eu = _repo.meuId;
    if (eu == null) return false;
    return switch (modo) {
      ModoConsultas.agente => c.agenteId == eu && c.solicitanteId != eu,
      ModoConsultas.gestao => c.gestorId == eu,
      ModoConsultas.usuario => false,
    };
  }

  bool get _gestao => modo == ModoConsultas.gestao;

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await _repo.listar();
      agentes = await _repo.agentes();
      final novas = [
        for (final c in itens)
          if (_souDestino(c) &&
              (_gestao ? c.gestorRecebidoEm : c.agenteRecebidoEm) == null)
            c.id,
      ];
      if (novas.isNotEmpty) {
        await _repo.marcar(
            _gestao ? 'gestor_recebido_em' : 'agente_recebido_em', novas);
        itens = await _repo.listar();
      }
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

  Future<String?> criar(ConsultaRascunho r) => _acao(() => _repo.criar(r));

  Future<String?> marcarVista(Consulta c) async {
    if (!_souDestino(c)) return null;
    if ((_gestao ? c.gestorVistoEm : c.agenteVistoEm) != null) return null;
    return _acao(() => _repo
        .marcar(_gestao ? 'gestor_visto_em' : 'agente_visto_em', [c.id]));
  }

  Future<String?> encaminhar(Consulta c, String usuario) =>
      _acao(() => _repo.encaminhar(c.id, usuario, extras: {
            if (_souDestino(c) && c.agenteVistoEm == null)
              'agente_visto_em': _agora,
          }));

  Future<String?> aceitar(Consulta c, DateTime quando) =>
      _acao(() => _repo.atualizar(c.id, {
            'status': 'aceita',
            'data_marcada': quando.toUtc().toIso8601String(),
            'motivo': null,
            if (_gestao && c.gestorVistoEm == null) 'gestor_visto_em': _agora,
          }));

  Future<String?> cancelar(Consulta c, String motivo) =>
      _acao(() => _repo.atualizar(c.id, {
            'status': 'cancelada',
            'motivo': motivo,
            if (_gestao && c.gestorVistoEm == null) 'gestor_visto_em': _agora,
          }));
}
