import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/familia.dart';
import '../models/membro.dart';
import 'app_exception.dart';
import 'usuario_atual.dart';

class FamiliaRepository {
  FamiliaRepository(this._c);
  final SupabaseClient _c;

  Future<List<Familia>> listarFamilias() async {
    final rows =
        await _c.from('acs_familias').select().order('responsavel').limit(1000);
    return rows.map(Familia.fromMap).toList();
  }

  Future<List<Membro>> listarMembros() async {
    final rows = await _c.from('acs_membros').select().order('nome').limit(5000);
    return rows.map(Membro.fromMap).toList();
  }

  Future<void> salvarFamilia(Familia f) async {
    if (f.id.isEmpty) {
      await _c
          .from('acs_familias')
          .insert({...f.toMap(), 'agente_id': idDoUsuario(_c)})
          .select('id')
          .single();
      return;
    }
    final row = await _c
        .from('acs_familias')
        .update(f.toMap())
        .eq('id', f.id)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível salvar a família. Verifique a permissão.');
    }
  }

  Future<void> salvarMembro(Membro m) async {
    if (m.id.isEmpty) {
      await _c
          .from('acs_membros')
          .insert({...m.toMap(), 'agente_id': idDoUsuario(_c)})
          .select('id')
          .single();
      return;
    }
    final row = await _c
        .from('acs_membros')
        .update(m.toMap())
        .eq('id', m.id)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível salvar a pessoa. Verifique a permissão.');
    }
  }

  Future<void> excluirMembro(String id) async {
    final rows = await _c.from('acs_membros').delete().eq('id', id).select('id');
    if (rows.isEmpty) {
      throw const AppException(
          'Não foi possível excluir a pessoa. Verifique a permissão.');
    }
  }
}
