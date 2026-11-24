import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class _Tabela {
  const _Tabela(this.nome,
      {this.dono, this.unicos = const [], this.restaurar = false, this.status});

  final String nome;

  /// Coluna que liga a linha ao login (só essas linhas entram no backup).
  final String? dono;

  /// Colunas únicas além do id, para não duplicar ao recuperar.
  final List<String> unicos;
  final bool restaurar;

  /// Só linhas com este status podem ser recriadas (regra do servidor).
  final String? status;
}

class BackupRepository {
  BackupRepository(this._c);
  final SupabaseClient _c;

  static const _tabelas = <Perfil, List<_Tabela>>{
    Perfil.usuario: [
      _Tabela('acs_consultas',
          dono: 'solicitante_id', restaurar: true, status: 'solicitada'),
    ],
    Perfil.agente: [
      _Tabela('acs_vacinas_tipos',
          dono: 'agente_id', unicos: ['nome'], restaurar: true),
      _Tabela('acs_familias', dono: 'agente_id', restaurar: true),
      _Tabela('acs_membros', dono: 'agente_id', restaurar: true),
      _Tabela('acs_vacinas',
          dono: 'agente_id', unicos: ['membro_id', 'tipo_id'], restaurar: true),
      _Tabela('acs_visitas',
          dono: 'agente_id', restaurar: true, status: 'agendada'),
      _Tabela('acs_consultas',
          dono: 'solicitante_id', restaurar: true, status: 'solicitada'),
      _Tabela('solicitacoes', dono: 'usuario_id'),
    ],
    Perfil.gestao: [
      _Tabela('reunioes', restaurar: true),
      _Tabela('stories', restaurar: true),
      _Tabela('solicitacoes'),
      _Tabela('acs_consultas'),
    ],
    Perfil.admin: [
      _Tabela('stories', restaurar: true),
      _Tabela('profiles'),
      _Tabela('logs'),
    ],
  };

  Future<Map<String, dynamic>> exportar(Perfil perfil, String uid) async {
    final dados = <String, dynamic>{};
    for (final t in _tabelas[perfil]!) {
      var q = _c.from(t.nome).select();
      if (t.dono != null) q = q.eq(t.dono!, uid);
      dados[t.nome] = await q.limit(10000);
    }
    return dados;
  }

  String _chave(Map<String, dynamic> m, List<String> cols) =>
      cols.map((c) => '${m[c]}').join('|');

  /// Recria no servidor só o que está no backup e falta no app.
  /// Retorna quantos registros foram recuperados.
  Future<int> restaurar(
      Perfil perfil, String uid, Map<String, dynamic> dados) async {
    var total = 0;
    for (final t in _tabelas[perfil]!.where((t) => t.restaurar)) {
      final linhas = (dados[t.nome] as List? ?? const [])
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((m) => t.dono == null || m[t.dono] == uid)
          .where((m) => t.status == null || m['status'] == t.status)
          .toList();
      if (linhas.isEmpty) continue;

      var q = _c.from(t.nome).select(['id', ...t.unicos].join(','));
      if (t.dono != null) q = q.eq(t.dono!, uid);
      final existentes = await q.limit(10000);
      final ids = {for (final e in existentes) e['id']};
      final chaves = {for (final e in existentes) _chave(e, t.unicos)};

      final faltando = linhas
          .where((m) =>
              !ids.contains(m['id']) &&
              (t.unicos.isEmpty || !chaves.contains(_chave(m, t.unicos))))
          .toList();
      if (faltando.isEmpty) continue;
      await _c.from(t.nome).insert(faltando);
      total += faltando.length;
    }
    return total;
  }
}
