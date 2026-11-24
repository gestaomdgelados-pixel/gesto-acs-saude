import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

String idDoUsuario(SupabaseClient c) {
  final uid = c.auth.currentUser?.id;
  if (uid == null) {
    throw const AppException('Sua sessão expirou. Entre novamente.');
  }
  return uid;
}
