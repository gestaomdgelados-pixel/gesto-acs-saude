import 'package:flutter/material.dart';

import '../repositories/prefs_repository.dart';
import '../theme/theme.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class TemaProvider extends SafeNotifier {
  TemaProvider(this._prefs);

  final PrefsRepository _prefs;
  ThemeMode modo = ThemeMode.system;
  String fonte = AppTheme.fontePadrao;
  Color cor = AppTheme.corPadrao;
  bool degrade = true;

  /// 0 = balão bem transparente, 1 = balão sólido (opaco). Ajustável pela pessoa.
  double transparenciaBalao = AppTheme.opacidadeBalaoPadrao;
  String? erro;

  Future<void> carregar() async {
    try {
      final salvo = await _prefs.modoTema();
      modo = ThemeMode.values
          .firstWhere((m) => m.name == salvo, orElse: () => ThemeMode.system);
      final a = await _prefs.aparencia();
      final f = a.fonte;
      if (f != null && AppTheme.fontes.contains(f)) fonte = f;
      final c = a.cor;
      if (c != null) cor = Color(c);
      degrade = a.degrade ?? true;
      transparenciaBalao =
          await _prefs.transparenciaBalao() ?? AppTheme.opacidadeBalaoPadrao;
    } catch (e) {
      erro = mensagemDeErro(e);
    }
    notifyListeners();
  }

  Future<void> definirFonte(String nova) => _aparencia(() => fonte = nova);
  Future<void> definirCor(Color nova) => _aparencia(() => cor = nova);
  Future<void> definirDegrade(bool novo) => _aparencia(() => degrade = novo);

  Future<void> definirTransparencia(double novo) async {
    transparenciaBalao = novo.clamp(0.0, 1.0);
    erro = null;
    notifyListeners();
    try {
      await _prefs.salvarTransparenciaBalao(transparenciaBalao);
    } catch (e) {
      erro = mensagemDeErro(e);
      notifyListeners();
    }
  }

  Future<void> _aparencia(void Function() mudar) async {
    mudar();
    erro = null;
    notifyListeners();
    try {
      await _prefs.salvarAparencia(
          fonte: fonte, cor: cor.toARGB32(), degrade: degrade);
    } catch (e) {
      erro = mensagemDeErro(e);
      notifyListeners();
    }
  }

  Future<void> definir(ThemeMode novo) async {
    modo = novo;
    erro = null;
    notifyListeners();
    try {
      await _prefs.salvarModoTema(novo.name);
    } catch (e) {
      erro = mensagemDeErro(e);
      notifyListeners();
    }
  }

  Future<void> alternar(Brightness atual) =>
      definir(atual == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
