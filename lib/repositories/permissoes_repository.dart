import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PermissoesRepository {
  PermissoesRepository(this._c);
  final SupabaseClient _c;
  static bool _iniciado = false;

  /// Lança erro quando não há conexão com o servidor.
  Future<void> testarInternet() async {
    await _c.from('acs_config').select('chave').limit(1);
  }

  Future<void> _iniciar() async {
    if (_iniciado) return;
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'avisos',
        channelName: 'Avisos',
        channelDescription: 'Avisos do Gestão ACS Saúde',
      ),
    ]);
    _iniciado = true;
  }

  /// null = não se aplica (navegador).
  Future<bool?> notificacoes() async {
    if (kIsWeb) return null;
    await _iniciar();
    return AwesomeNotifications().isNotificationAllowed();
  }

  Future<bool?> pedirNotificacoes() async {
    if (kIsWeb) return null;
    await _iniciar();
    return AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
