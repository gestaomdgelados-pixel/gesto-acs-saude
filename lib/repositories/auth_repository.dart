import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/profile.dart';

class AuthRepository {
  AuthRepository(this._c);
  final SupabaseClient _c;

  User? get usuarioAtual => _c.auth.currentUser;
  Stream<AuthState> get mudancas => _c.auth.onAuthStateChange;

  /// Marcado pelo servidor quando a senha foi criada/trocada pelo admin.
  bool get precisaTrocarSenha =>
      _c.auth.currentUser?.userMetadata?['trocar_senha'] == true;

  static String emailDe(String usuario) =>
      '${usuario.trim().toLowerCase()}@${SupabaseConfig.emailDomain}';

  Future<void> entrar(String usuario, String senha) async {
    await _c.auth.signInWithPassword(email: emailDe(usuario), password: senha);
  }

  Future<void> sair() => _c.auth.signOut();

  Future<Profile?> perfil(String id) async {
    final row =
        await _c.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<void> trocarSenha(String nova) async {
    await _c.auth.updateUser(
      UserAttributes(password: nova, data: {'trocar_senha': false}),
    );
  }
}
