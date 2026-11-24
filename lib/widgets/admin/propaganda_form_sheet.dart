import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';

class PropagandaFormSheet extends StatefulWidget {
  const PropagandaFormSheet({
    super.key,
    required this.onPublicar,
    this.titulo = 'Nova propaganda',
    this.botao = 'Publicar para todos',
  });

  final Future<String?> Function(PropagandaRascunho r) onPublicar;
  final String titulo;
  final String botao;

  @override
  State<PropagandaFormSheet> createState() => _PropagandaFormSheetState();
}

class _PropagandaFormSheetState extends State<PropagandaFormSheet> {
  static const _limiteBytes = 50 * 1024 * 1024;
  static const _mimes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'webm': 'video/webm',
  };

  final _titulo = TextEditingController();
  final _texto = TextEditingController();
  Uint8List? _bytes;
  String _nome = '';
  String _mime = '';
  bool _isVideo = false;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _titulo.dispose();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _escolher(bool video) async {
    final picker = ImagePicker();
    final arquivo = video
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (arquivo == null) return; // seleção cancelada
    final bytes = await arquivo.readAsBytes();
    if (bytes.length > _limiteBytes) {
      setState(() => _erro = 'Arquivo maior que 50 MB. Escolha um menor.');
      return;
    }
    final ext = arquivo.name.contains('.')
        ? arquivo.name.split('.').last.toLowerCase()
        : (video ? 'mp4' : 'jpg');
    setState(() {
      _bytes = bytes;
      _nome = arquivo.name;
      _isVideo = video;
      _mime = arquivo.mimeType ?? _mimes[ext] ?? (video ? 'video/mp4' : 'image/jpeg');
      _erro = null;
    });
  }

  Future<void> _publicar() async {
    final bytes = _bytes;
    if (bytes == null) {
      setState(() => _erro = 'Escolha uma imagem ou um vídeo.');
      return;
    }
    if (_titulo.text.trim().isEmpty) {
      setState(() => _erro = 'Informe o título.');
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final ext = _nome.contains('.') ? _nome.split('.').last.toLowerCase() : 'bin';
    final erro = await widget.onPublicar(PropagandaRascunho(
      bytes: bytes,
      extensao: ext,
      mime: _mime,
      isVideo: _isVideo,
      titulo: _titulo.text.trim(),
      texto: _texto.text.trim().isEmpty ? null : _texto.text.trim(),
    ));
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _enviando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bytes = _bytes;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.titulo,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: SizedBox(
                height: AppTheme.propagandaHeight,
                child: bytes != null && !_isVideo
                    ? Image.memory(bytes, fit: BoxFit.cover)
                    : ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  _isVideo
                                      ? Icons.videocam_rounded
                                      : Icons.add_photo_alternate_rounded,
                                  size: AppTheme.iconXl,
                                  color: colors.onSurfaceVariant),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(bytes == null ? 'Nenhum arquivo' : _nome,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _enviando ? null : () => _escolher(false),
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('Imagem'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _enviando ? null : () => _escolher(true),
                    icon: const Icon(Icons.videocam_rounded),
                    label: const Text('Vídeo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _titulo,
              decoration: const InputDecoration(
                  labelText: 'Título (ex.: Reinauguração do posto)'),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _texto,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Legenda (opcional)'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: _erro!),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton(
              onPressed: _enviando ? null : _publicar,
              child: Text(_enviando ? 'Enviando…' : widget.botao),
            ),
          ],
        ),
      ),
    );
  }
}
