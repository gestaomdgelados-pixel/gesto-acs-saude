import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parse.dart';
import '../models/vacina.dart';
import 'app_exception.dart';
import 'usuario_atual.dart';

class VacinaRepository {
  VacinaRepository(this._c);
  final SupabaseClient _c;

  Future<List<VacinaTipo>> listarTipos() async {
    final rows = await _c.from('acs_vacinas_tipos').select().order('nome');
    return rows.map(VacinaTipo.fromMap).toList();
  }

  Future<List<VacinaRegistro>> listarRegistros() async {
    final rows = await _c.from('acs_vacinas').select().limit(10000);
    return rows.map(VacinaRegistro.fromMap).toList();
  }

  Future<void> criarTipo(String nome, String? descricao) async {
    try {
      await _c
          .from('acs_vacinas_tipos')
          .insert({
            'agente_id': idDoUsuario(_c),
            'nome': nome,
            'descricao': descricao,
          })
          .select('id')
          .single();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException('Já existe uma vacina com esse nome.');
      }
      rethrow;
    }
  }

  Future<void> excluirTipo(String id) async {
    final rows =
        await _c.from('acs_vacinas_tipos').delete().eq('id', id).select('id');
    if (rows.isEmpty) {
      throw const AppException(
          'Não foi possível excluir a vacina. Verifique a permissão.');
    }
  }

  Future<void> agendar(String membroId, String tipoId, DateTime data) async {
    await _c
        .from('acs_vacinas')
        .upsert({
          'agente_id': idDoUsuario(_c),
          'membro_id': membroId,
          'tipo_id': tipoId,
          'status': 'agendada',
          'data_prevista': dataSql(data),
        }, onConflict: 'membro_id,tipo_id')
        .select('id')
        .single();
  }

  Future<void> concluir(
    String membroId,
    String tipoId, {
    required DateTime aplicadaEm,
    required String aplicadoPor,
    required String lote,
  }) async {
    await _c
        .from('acs_vacinas')
        .upsert({
          'agente_id': idDoUsuario(_c),
          'membro_id': membroId,
          'tipo_id': tipoId,
          'status': 'concluida',
          'aplicada_em': dataSql(aplicadaEm),
          'aplicado_por': aplicadoPor,
          'lote': lote,
        }, onConflict: 'membro_id,tipo_id')
        .select('id')
        .single();
  }

  Future<void> excluirRegistro(String id) async {
    final rows = await _c.from('acs_vacinas').delete().eq('id', id).select('id');
    if (rows.isEmpty) {
      throw const AppException(
          'Não foi possível excluir o registro. Verifique a permissão.');
    }
  }
}
