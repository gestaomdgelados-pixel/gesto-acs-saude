import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

typedef LoginEncontrado = ({String id, String nome, String usuario});

/// Só encontra se o nome de usuário for exatamente de um login ativo da gestão.
Future<LoginEncontrado> buscarLoginGestao(
    SupabaseClient c, String digitado) async {
  final usuario = digitado.trim().replaceFirst('@', '').toLowerCase();
  if (usuario.isEmpty) {
    throw const AppException('Digite o nome de usuário da pessoa da gestão.');
  }
  final rows = await c.rpc('acs_buscar_login',
      params: {'p_usuario': usuario, 'p_role': 'gestao'}) as List;
  if (rows.isEmpty) {
    throw AppException(
        'Nenhum login da gestão com o usuário "$usuario". Nada foi enviado. '
        'Confira o nome e tente de novo.');
  }
  final r = rows.first as Map<String, dynamic>;
  return (
    id: r['id'] as String,
    nome: (r['nome'] ?? usuario) as String,
    usuario: usuario,
  );
}
