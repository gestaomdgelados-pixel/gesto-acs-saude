import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/aviso.dart';
import '../models/story.dart';
import 'app_exception.dart';

class StoryRepository {
  StoryRepository(this._c);
  final SupabaseClient _c;

  String get _uid {
    final id = _c.auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Sua sessão expirou. Entre novamente.');
    }
    return id;
  }

  Future<List<Story>> listar({bool incluirInativos = false}) async {
    var q = _c.from('stories').select();
    if (!incluirInativos) q = q.eq('ativo', true);
    final rows = await q.order('created_at', ascending: false);
    final lista = rows.map(Story.fromMap).toList();
    return incluirInativos ? lista : lista.where((s) => !s.expirada).toList();
  }

  Future<void> publicarMidia(PropagandaRascunho r) async {
    final uid = _uid;
    final caminho =
        '$uid/${DateTime.now().millisecondsSinceEpoch}.${r.extensao}';
    final bucket = _c.storage.from(SupabaseConfig.bucketPropagandas);
    await bucket.uploadBinary(caminho, r.bytes,
        fileOptions: FileOptions(contentType: r.mime));
    try {
      await _c.from('stories').insert({
        'titulo': r.titulo,
        'texto': r.texto,
        'midia_url': bucket.getPublicUrl(caminho),
        'midia_tipo': r.isVideo ? 'video' : 'imagem',
        'ativo': true,
        'criado_por': uid,
      }).select('id').single();
    } catch (_) {
      // O arquivo novo não está ligado a nenhuma propaganda: remove e repassa o erro.
      await bucket.remove([caminho]);
      rethrow;
    }
  }

  Future<void> publicarCampanha(AvisoRascunho r) async {
    await _c.from('stories').insert({
      'titulo': r.titulo,
      'texto': r.descricao,
      'cor': r.cor,
      'ativo': true,
      'criado_por': _uid,
    }).select('id').single();
  }

  Future<Set<String>> vistos() async {
    final rows = await _c
        .from('acs_stories_vistos')
        .select('story_id')
        .eq('usuario_id', _uid);
    return {for (final r in rows) r['story_id'] as String};
  }

  Future<void> marcarVisto(String id) async {
    await _c.from('acs_stories_vistos').upsert(
      {'story_id': id, 'usuario_id': _uid},
      onConflict: 'story_id,usuario_id',
      ignoreDuplicates: true,
    );
  }

  Future<void> alterarAtivo(String id, bool ativo) async {
    final row = await _c
        .from('stories')
        .update({'ativo': ativo})
        .eq('id', id)
        .select('id')
        .maybeSingle();
    if (row == null) {
      throw const AppException(
          'Não foi possível alterar a propaganda. Verifique a permissão.');
    }
  }

  Future<void> excluir(String id) async {
    final rows = await _c.from('stories').delete().eq('id', id).select('id');
    if (rows.isEmpty) {
      throw const AppException(
          'Não foi possível excluir a propaganda. Verifique a permissão.');
    }
  }
}
