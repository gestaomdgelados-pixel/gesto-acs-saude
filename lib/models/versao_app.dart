import 'parse.dart';

class VersaoApp {
  const VersaoApp({
    required this.id,
    required this.versao,
    this.notas,
    this.arquivoUrl,
    this.criadoEm,
  });

  final String id;
  final String versao;
  final String? notas;
  final String? arquivoUrl;
  final DateTime? criadoEm;

  factory VersaoApp.fromMap(Map<String, dynamic> m) => VersaoApp(
        id: m['id'] as String,
        versao: (m['versao'] ?? '') as String,
        notas: m['notas'] as String?,
        arquivoUrl: m['arquivo_url'] as String?,
        criadoEm: lerData(m['created_at']),
      );

  /// Compara "1.2.3": positivo quando [a] é mais nova que [b].
  static int comparar(String a, String b) {
    List<int> partes(String v) => v
        .split('+')
        .first
        .trim()
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    final x = partes(a);
    final y = partes(b);
    for (var i = 0; i < 3; i++) {
      final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
      if (d != 0) return d.sign;
    }
    return 0;
  }
}
