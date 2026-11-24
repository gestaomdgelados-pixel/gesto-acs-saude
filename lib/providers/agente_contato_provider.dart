import '../models/agente_contato.dart';
import '../repositories/app_exception.dart';
import '../repositories/contato_agente_repository.dart';
import 'safe_notifier.dart';

class AgenteContatoProvider extends SafeNotifier {
  AgenteContatoProvider(this._repo);
  final ContatoAgenteRepository _repo;

  AgenteContato? contato;
  String? erro;

  String _msg(Object e) => e is AppException ? e.message : 'Erro: $e';

  Future<void> carregar() async {
    try {
      contato = await _repo.meuContato();
      erro = null;
    } catch (e) {
      erro = _msg(e);
    }
    notifyListeners();
  }

  Future<String?> salvar(AgenteContato c) async {
    try {
      await _repo.salvar(c);
      contato = c;
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  /// Retorna (nome do morador, erro).
  Future<(String?, String?)> vincular(String familiaId, String usuario) async {
    try {
      return (await _repo.vincular(familiaId, usuario), null);
    } catch (e) {
      return (null, _msg(e));
    }
  }
}
