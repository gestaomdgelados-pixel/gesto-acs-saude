import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/agente_contato.dart';
import '../models/membro.dart';
import '../models/vacina.dart';
import '../models/visita.dart';
import 'app_exception.dart';
import 'usuario_atual.dart';

class MoradorDados {
  const MoradorDados({
    required this.vinculado,
    this.membros = const [],
    this.tipos = const [],
    this.registros = const [],
    this.visitas = const [],
  });

  final bool vinculado;
  final List<Membro> membros;
  final List<VacinaTipo> tipos;
  final List<VacinaRegistro> registros;
  final List<Visita> visitas;
}

class MoradorRepository {
  MoradorRepository(this._c);
  final SupabaseClient _c;

  Future<T> _rodar<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<MoradorDados> carregar() => _rodar(() async {
        final fams = await _c
            .from('acs_familias')
            .select('id')
            .eq('usuario_id', idDoUsuario(_c));
        final ids = fams.map((r) => r['id'] as String).toList();
        if (ids.isEmpty) return const MoradorDados(vinculado: false);

        final membros = (await _c
                .from('acs_membros')
                .select()
                .inFilter('familia_id', ids)
                .order('nome'))
            .map(Membro.fromMap)
            .toList();
        final mids = membros.map((m) => m.id).toList();
        final tipos = (await _c.from('acs_vacinas_tipos').select().order('nome'))
            .map(VacinaTipo.fromMap)
            .toList();
        final registros = mids.isEmpty
            ? <VacinaRegistro>[]
            : (await _c.from('acs_vacinas').select().inFilter('membro_id', mids))
                .map(VacinaRegistro.fromMap)
                .toList();
        final visitas = (await _c
                .from('acs_visitas')
                .select()
                .inFilter('familia_id', ids)
                .order('agendada_para', ascending: false))
            .map(Visita.fromMap)
            .toList();
        return MoradorDados(
          vinculado: true,
          membros: membros,
          tipos: tipos,
          registros: registros,
          visitas: visitas,
        );
      });

  Future<AgenteContato?> contatoDoAgente() => _rodar(() async {
        final rows = await _c.rpc('acs_contato_do_agente') as List;
        if (rows.isEmpty) return null;
        return AgenteContato.fromMap(
            Map<String, dynamic>.from(rows.first as Map));
      });

  Future<void> cancelarVisita(String id, String motivo) => _rodar(() async {
        await _c.rpc('acs_cancelar_visita',
            params: {'p_id': id, 'p_motivo': motivo});
      });
}
