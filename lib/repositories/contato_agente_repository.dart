import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/agente_contato.dart';
import 'app_exception.dart';
import 'usuario_atual.dart';

class ContatoAgenteRepository {
  ContatoAgenteRepository(this._c);
  final SupabaseClient _c;

  Future<AgenteContato?> meuContato() async {
    try {
      final row = await _c
          .from('acs_agente_contato')
          .select()
          .eq('agente_id', idDoUsuario(_c))
          .maybeSingle();
      return row == null ? null : AgenteContato.fromMap(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<void> salvar(AgenteContato c) async {
    try {
      await _c
          .from('acs_agente_contato')
          .upsert({
            ...c.toMap(),
            'agente_id': idDoUsuario(_c),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select('agente_id')
          .single();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  /// Devolve o nome do morador vinculado.
  Future<String> vincular(String familiaId, String usuario) async {
    try {
      final r = await _c.rpc('acs_vincular_morador',
          params: {'p_familia': familiaId, 'p_usuario': usuario});
      return '${r ?? ''}';
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }
}
