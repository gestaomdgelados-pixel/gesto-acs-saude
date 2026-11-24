/// Dados públicos de conexão com o Supabase. Nenhuma chave secreta fica aqui.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://xcojwethqzwytbzyvscd.supabase.co';
  static const String publishableKey =
      'sb_publishable_OGLzWiZxKP4vxm5_3eQvlA_Cb4cgAqA';

  /// O login é feito por nome de usuário; internamente vira usuario@dominio.
  static const String emailDomain = 'seuapp.com';

  /// Pasta pública do Storage com as imagens e vídeos de propaganda.
  static const String bucketPropagandas = 'propagandas';

  /// Edge Function que só o admin pode chamar (criar/editar/excluir logins).
  static const String adminFunction = 'bright-function';
}
