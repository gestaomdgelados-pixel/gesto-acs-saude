import 'dart:typed_data';

import 'parse.dart';

class Story {
  const Story({
    required this.id,
    required this.titulo,
    required this.ativo,
    this.texto,
    this.cor,
    this.expiraEm,
    this.midiaUrl,
    this.midiaTipo,
    this.criadoEm,
  });

  final String id;
  final String titulo;
  final bool ativo;
  final String? texto;
  final String? cor;
  final DateTime? expiraEm;
  final String? midiaUrl;
  final String? midiaTipo;
  final DateTime? criadoEm;

  bool get temMidia => midiaUrl != null && midiaUrl!.isNotEmpty;
  bool get isVideo => temMidia && midiaTipo == 'video';
  bool get isCampanhaTexto => !temMidia;
  bool get expirada => expiraEm != null && expiraEm!.isBefore(DateTime.now());

  factory Story.fromMap(Map<String, dynamic> m) => Story(
        id: m['id'] as String,
        titulo: (m['titulo'] ?? '') as String,
        ativo: (m['ativo'] ?? true) as bool,
        texto: m['texto'] as String?,
        cor: m['cor'] as String?,
        expiraEm: lerData(m['expira_em']),
        midiaUrl: m['midia_url'] as String?,
        midiaTipo: m['midia_tipo'] as String?,
        criadoEm: lerData(m['created_at']),
      );
}

/// Imagem ou vídeo escolhido pelo admin para virar propaganda.
class PropagandaRascunho {
  const PropagandaRascunho({
    required this.bytes,
    required this.extensao,
    required this.mime,
    required this.isVideo,
    required this.titulo,
    this.texto,
  });

  final Uint8List bytes;
  final String extensao;
  final String mime;
  final bool isVideo;
  final String titulo;
  final String? texto;
}
