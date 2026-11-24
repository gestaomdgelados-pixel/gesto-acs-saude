import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/aviso.dart';
import 'app_exception.dart';

class AvisoRepository {
  AvisoRepository(this._c);
  final SupabaseClient _c;

  Future<List<Aviso>> listar() async {
    final rows = await _c
        .from('reunioes')
        .select()
        .order('data', ascending: false)
        .limit(100);
    return rows.map(Aviso.fromMap).toList();
  }

  Future<void> criar(AvisoRascunho r) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) {
      throw const AppException('Sua sessão expirou. Entre novamente.');
    }
    await _c.from('reunioes').insert({
      'titulo': r.titulo,
      'descricao': r.descricao,
      'data': r.data.toUtc().toIso8601String(),
      'tipo': r.tipo,
      'criado_por': uid,
    }).select('id').single();
  }

  Future<void> excluir(String id) async {
    final rows = await _c.from('reunioes').delete().eq('id', id).select('id');
    if (rows.isEmpty) {
      throw const AppException(
          'Não foi possível excluir. Verifique a permissão.');
    }
  }
}
