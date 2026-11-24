import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/arquivo_escolhido.dart';
import '../models/versao_app.dart';
import 'usuario_atual.dart';

class ConfigRepository {
  ConfigRepository(this._c);
  final SupabaseClient _c;
  static const _bucketVersoes = 'versoes';

  Future<String?> telefoneAdmin() async {
    final row = await _c
        .from('acs_config')
        .select('valor')
        .eq('chave', 'admin_telefone')
        .maybeSingle();
    return row?['valor'] as String?;
  }

  Future<void> salvarTelefoneAdmin(String telefone) async {
    await _c.from('acs_config').upsert({
      'chave': 'admin_telefone',
      'valor': telefone,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).select('chave').single();
  }

  Future<VersaoApp?> ultimaVersao() async {
    final rows = await _c
        .from('acs_versoes')
        .select()
        .order('created_at', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : VersaoApp.fromMap(rows.first);
  }

  Future<String> versaoInstalada() async =>
      (await PackageInfo.fromPlatform()).version;

  Future<void> publicarVersao(
      ArquivoEscolhido a, String versao, String? notas) async {
    final ext = a.extensao.isEmpty ? 'apk' : a.extensao;
    final caminho =
        '${DateTime.now().millisecondsSinceEpoch}_${versao.replaceAll(RegExp(r'[^0-9.]'), '')}.$ext';
    final bucket = _c.storage.from(_bucketVersoes);
    await bucket.uploadBinary(caminho, a.bytes,
        fileOptions: FileOptions(
            contentType: ext == 'apk'
                ? 'application/vnd.android.package-archive'
                : 'application/octet-stream'));
    try {
      await _c.from('acs_versoes').insert({
        'versao': versao,
        'notas': notas,
        'arquivo_url': bucket.getPublicUrl(caminho),
        'criado_por': idDoUsuario(_c),
      }).select('id').single();
    } catch (_) {
      await bucket.remove([caminho]);
      rethrow;
    }
  }
}
