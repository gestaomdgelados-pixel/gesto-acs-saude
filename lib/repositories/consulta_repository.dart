import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/consulta.dart';
import 'app_exception.dart';
import 'login_busca.dart';
import 'usuario_atual.dart';

class ConsultaRepository {
  ConsultaRepository(this._c);
  final SupabaseClient _c;

  String? get meuId => _c.auth.currentUser?.id;

  Future<List<Consulta>> listar() async {
    final rows = await _c
        .from('acs_consultas')
        .select()
        .order('created_at', ascending: false)
        .limit(300);
    return rows.map(Consulta.fromMap).toList();
  }

  Future<List<OpcaoPessoa>> agentes() async {
    final rows = await _c.rpc('acs_agentes');
    return [
      for (final r in rows as List)
        OpcaoPessoa(r['id'] as String, (r['nome'] ?? 'Agente') as String),
    ];
  }

  Future<void> criar(ConsultaRascunho r) async {
    await _c.from('acs_consultas').insert({
      'solicitante_id': idDoUsuario(_c),
      'agente_id': r.agenteId,
      'membro_id': r.membroId,
      'paciente': r.paciente,
      'especialidade': r.especialidade,
      'observacao': r.observacao,
      'status': 'solicitada',
    }).select('id').single();
  }

  Future<void> atualizar(String id, Map<String, dynamic> dados) async {
    final row = await _c
        .from('acs_consultas')
        .update(dados)
        .eq('id', id)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível atualizar a consulta. Verifique a permissão.');
    }
  }

  /// Envia para UMA pessoa da gestão, achada pelo nome de usuário exato.
  Future<String> encaminhar(String id, String usuarioGestao,
      {Map<String, dynamic> extras = const {}}) async {
    final g = await buscarLoginGestao(_c, usuarioGestao);
    await atualizar(id, {
      'gestor_id': g.id,
      'gestor_usuario': g.usuario,
      'encaminhada_em': DateTime.now().toUtc().toIso8601String(),
      'gestor_recebido_em': null,
      'gestor_visto_em': null,
      ...extras,
    });
    return g.usuario;
  }

  Future<void> marcar(String coluna, List<String> ids) async {
    await _c
        .from('acs_consultas')
        .update({coluna: DateTime.now().toUtc().toIso8601String()})
        .inFilter('id', ids);
  }
}
