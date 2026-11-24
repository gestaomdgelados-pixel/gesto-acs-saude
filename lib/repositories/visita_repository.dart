import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visita.dart';
import 'app_exception.dart';
import 'usuario_atual.dart';

class VisitaRepository {
  VisitaRepository(this._c);
  final SupabaseClient _c;

  Future<List<Visita>> listar() async {
    final rows = await _c
        .from('acs_visitas')
        .select()
        .order('agendada_para', ascending: false)
        .limit(3000);
    return rows.map(Visita.fromMap).toList();
  }

  Future<void> agendar(
      String familiaId, DateTime quando, String motivo) async {
    await _c
        .from('acs_visitas')
        .insert({
          'agente_id': idDoUsuario(_c),
          'familia_id': familiaId,
          'agendada_para': quando.toUtc().toIso8601String(),
          'motivo': motivo,
          'status': 'agendada',
        })
        .select('id')
        .single();
  }

  Future<void> concluir(String id, Map<String, String> respostas) async {
    final row = await _c
        .from('acs_visitas')
        .update({
          'status': 'concluida',
          'concluida_em': DateTime.now().toUtc().toIso8601String(),
          'questionario': respostas,
        })
        .eq('id', id)
        .eq('status', 'agendada')
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível concluir a visita. Ela pode já ter sido concluída.');
    }
  }

  Future<void> justificar(String id, String justificativa) async {
    final row = await _c
        .from('acs_visitas')
        .update({'status': 'nao_realizada', 'justificativa': justificativa})
        .eq('id', id)
        .eq('status', 'agendada')
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível justificar a visita. Ela pode já ter sido encerrada.');
    }
  }
}
