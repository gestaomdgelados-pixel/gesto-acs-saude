import 'package:flutter/foundation.dart';

/// ChangeNotifier que ignora avisos depois de descartado (respostas atrasadas).
class SafeNotifier extends ChangeNotifier {
  bool _descartado = false;

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
