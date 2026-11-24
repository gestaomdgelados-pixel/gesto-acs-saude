import 'package:shared_preferences/shared_preferences.dart';

/// Dados que ficam só no aparelho (não vão para o servidor).
class PrefsRepository {
  static const _ultimoUsuario = 'ultimo_usuario';
  static const _modoTema = 'modo_tema';

  Future<String?> modoTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modoTema);
  }

  Future<void> salvarModoTema(String modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modoTema, modo);
  }

  static const _fonte = 'tema_fonte';
  static const _cor = 'tema_cor';
  static const _degrade = 'tema_degrade';

  Future<({String? fonte, int? cor, bool? degrade})> aparencia() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      fonte: prefs.getString(_fonte),
      cor: prefs.getInt(_cor),
      degrade: prefs.getBool(_degrade),
    );
  }

  Future<void> salvarAparencia(
      {required String fonte, required int cor, required bool degrade}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fonte, fonte);
    await prefs.setInt(_cor, cor);
    await prefs.setBool(_degrade, degrade);
  }

  static const _transparenciaBalao = 'tema_transparencia_balao';

  Future<double?> transparenciaBalao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_transparenciaBalao);
  }

  Future<void> salvarTransparenciaBalao(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_transparenciaBalao, valor);
  }

  Future<String> ultimoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ultimoUsuario) ?? '';
  }

  Future<void> salvarUltimoUsuario(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ultimoUsuario, usuario);
  }
}
