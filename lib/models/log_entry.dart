import 'parse.dart';

class LogEntry {
  const LogEntry({
    required this.id,
    required this.acao,
    this.usuarioId,
    this.detalhe,
    this.criadoEm,
  });

  final String id;
  final String acao;
  final String? usuarioId;
  final String? detalhe;
  final DateTime? criadoEm;

  factory LogEntry.fromMap(Map<String, dynamic> m) => LogEntry(
        id: m['id'] as String,
        acao: (m['acao'] ?? '') as String,
        usuarioId: m['usuario_id'] as String?,
        detalhe: m['detalhe'] as String?,
        criadoEm: lerData(m['created_at']),
      );
}
