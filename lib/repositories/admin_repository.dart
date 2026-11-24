import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/log_entry.dart';
import '../models/profile.dart';
import 'app_exception.dart';

/// Criar, editar, trocar senha e excluir logins passam pela Edge Function
/// `bright-function`, que confere no servidor se quem chamou é admin.
class AdminRepository {
  AdminRepository(this._c);
  final SupabaseClient _c;

  Future<void> _chamar(Map<String, dynamic> body) async {
    final res =
        await _c.functions.invoke(SupabaseConfig.adminFunction, body: body);
    final data = res.data;
    if (data is Map && data['error'] != null) {
      throw AppException('${data['error']}');
    }
  }

  Future<List<Profile>> listarUsuarios() async {
    final rows = await _c.from('profiles').select().order('nome');
    return rows.map(Profile.fromMap).toList();
  }

  Future<List<LogEntry>> listarLogs() async {
    final rows = await _c
        .from('logs')
        .select()
        .order('created_at', ascending: false)
        .limit(200);
    return rows.map(LogEntry.fromMap).toList();
  }

  Future<void> criar(LoginDados d) => _chamar({
        'acao': 'criar',
        'nome': d.nome,
        'usuario': d.usuario.trim().toLowerCase(),
        'senha': d.senha,
        'perfil': d.perfil.name,
        'agente_id': d.agenteId,
      });

  Future<void> editar(String id, LoginDados d) => _chamar({
        'acao': 'editar',
        'id': id,
        'nome': d.nome,
        'perfil': d.perfil.name,
        'agente_id': d.agenteId,
        'ativo': d.ativo,
      });

  Future<void> trocarSenha(String id, String senha) =>
      _chamar({'acao': 'senha', 'id': id, 'senha': senha});

  Future<void> excluir(String id) => _chamar({'acao': 'excluir', 'id': id});
}
