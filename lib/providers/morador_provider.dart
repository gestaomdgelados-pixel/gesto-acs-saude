import '../models/agente_contato.dart';
import '../models/membro.dart';
import '../models/vacina.dart';
import '../models/visita.dart';
import '../repositories/app_exception.dart';
import '../repositories/morador_repository.dart';
import 'safe_notifier.dart';

class MoradorProvider extends SafeNotifier {
  MoradorProvider(this._repo);
  final MoradorRepository _repo;

  MoradorDados _dados = const MoradorDados(vinculado: true);
  AgenteContato? contato;
  bool carregando = false;
  String? erro;

  bool get vinculado => _dados.vinculado;
  List<Membro> get membros => _dados.membros;
  List<Visita> get visitas => _dados.visitas;

  List<Visita> get proximas => visitas
      .where((v) => v.status == StatusVisita.agendada)
      .toList()
    ..sort((a, b) => a.agendadaPara.compareTo(b.agendadaPara));
  List<Visita> get realizadas =>
      visitas.where((v) => v.status == StatusVisita.concluida).toList();
  List<Visita> get canceladas =>
      visitas.where((v) => v.status == StatusVisita.naoRealizada).toList();

  List<VacinaItem> carteiraDe(String membroId) => [
        for (final t in _dados.tipos)
          VacinaItem(
            t,
            _dados.registros
                .where((r) => r.membroId == membroId && r.tipoId == t.id)
                .firstOrNull,
          ),
      ];

  String _msg(Object e) => e is AppException ? e.message : 'Erro: $e';

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      _dados = await _repo.carregar();
      contato = await _repo.contatoDoAgente();
    } catch (e) {
      erro = _msg(e);
    }
    carregando = false;
    notifyListeners();
  }

  Future<String?> cancelarVisita(String id, String motivo) async {
    try {
      await _repo.cancelarVisita(id, motivo);
      await carregar();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }
}
