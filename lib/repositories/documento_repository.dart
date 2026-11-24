import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/arquivo_escolhido.dart';
import '../models/documento.dart';
import 'login_busca.dart';
import 'usuario_atual.dart';

class DocumentoRepository {
  DocumentoRepository(this._c);
  final SupabaseClient _c;
  static const _bucket = 'documentos';

  Future<List<Documento>> listar({required bool recebidos}) async {
    final rows = await _c
        .from('acs_documentos')
        .select()
        .eq(recebidos ? 'destinatario_id' : 'remetente_id', idDoUsuario(_c))
        .order('created_at', ascending: false)
        .limit(300);
    return rows.map(Documento.fromMap).toList();
  }

  /// Só envia se o usuário digitado for de um login ativo da gestão.
  Future<String> enviar(
      ArquivoEscolhido a, String usuarioGestao, String meuNome) async {
    final g = await buscarLoginGestao(_c, usuarioGestao);
    final uid = idDoUsuario(_c);
    final caminho = '$uid/${DateTime.now().millisecondsSinceEpoch}.pdf';
    final bucket = _c.storage.from(_bucket);
    await bucket.uploadBinary(caminho, a.bytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'));
    try {
      await _c.from('acs_documentos').insert({
        'remetente_id': uid,
        'remetente_nome': meuNome,
        'destinatario_id': g.id,
        'destinatario_usuario': g.usuario,
        'nome_arquivo': a.nome,
        'caminho': caminho,
      }).select('id').single();
    } catch (_) {
      // O PDF não ficou ligado a nenhum envio: remove e repassa o erro.
      await bucket.remove([caminho]);
      rethrow;
    }
    return g.usuario;
  }

  Future<void> marcar(String coluna, List<String> ids) async {
    await _c
        .from('acs_documentos')
        .update({coluna: DateTime.now().toUtc().toIso8601String()})
        .inFilter('id', ids);
  }

  Future<String> link(String caminho) =>
      _c.storage.from(_bucket).createSignedUrl(caminho, 600);
}
