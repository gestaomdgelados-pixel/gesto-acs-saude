import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/solicitacao.dart';
import 'app_exception.dart';

class SolicitacaoRepository {
  SolicitacaoRepository(this._c);
  final SupabaseClient _c;

  Future<List<Solicitacao>> listar({String? agenteId}) async {
    var q = _c.from('solicitacoes').select();
    if (agenteId != null) q = q.eq('agente_id', agenteId);
    final rows = await q.order('created_at', ascending: false).limit(200);
    return rows.map(Solicitacao.fromMap).toList();
  }

  Future<void> criar(SolicitacaoRascunho r) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) {
      throw const AppException('Sua sessão expirou. Entre novamente.');
    }
    final d = r.dataDesejada;
    await _c.from('solicitacoes').insert({
      'usuario_id': uid,
      'agente_id': uid,
      'especialidade': '${r.tipo}${Solicitacao.separador}${r.assunto}',
      'data_desejada': d == null
          ? null
          : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'observacao': r.observacao,
      'status': 'pendente',
    }).select('id').single();
  }

  Future<void> decidir(String id,
      {required String status, DateTime? dataAgendada, String? motivo}) async {
    final row = await _c
        .from('solicitacoes')
        .update({
          'status': status,
          'data_agendada': dataAgendada?.toUtc().toIso8601String(),
          'motivo_recusa': motivo,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível atualizar a solicitação. Verifique a permissão.');
    }
  }
}
