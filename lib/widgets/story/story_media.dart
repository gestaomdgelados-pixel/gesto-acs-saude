import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';

class StoryMedia extends StatefulWidget {
  const StoryMedia({
    super.key,
    required this.story,
    required this.onVideoPronto,
    required this.onVideoErro,
    required this.onVideoFim,
    this.pausado = false,
  });

  final Story story;
  final ValueChanged<Duration> onVideoPronto;
  final VoidCallback onVideoErro;
  final VoidCallback onVideoFim;
  final bool pausado;

  @override
  State<StoryMedia> createState() => _StoryMediaState();
}

class _StoryMediaState extends State<StoryMedia> {
  VideoPlayerController? _video;
  String? _erro;
  bool _terminou = false;

  @override
  void initState() {
    super.initState();
    if (widget.story.isVideo) _iniciarVideo();
  }

  @override
  void didUpdateWidget(covariant StoryMedia old) {
    super.didUpdateWidget(old);
    final v = _video;
    if (v == null || !v.value.isInitialized || old.pausado == widget.pausado) {
      return;
    }
    widget.pausado ? v.pause() : v.play();
  }

  void _ouvir() {
    final v = _video;
    if (v == null || _terminou || !v.value.isCompleted) return;
    _terminou = true;
    widget.onVideoFim();
  }

  Future<void> _iniciarVideo() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.story.midiaUrl!));
    _video = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      controller.addListener(_ouvir);
      if (!widget.pausado) await controller.play();
      widget.onVideoPronto(controller.value.duration);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar o vídeo: $e');
      widget.onVideoErro();
    }
  }

  @override
  void dispose() {
    _video?.removeListener(_ouvir);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final s = widget.story;

    Widget legenda(String t) => Text(t,
        textAlign: TextAlign.center,
        style: text.titleMedium?.copyWith(color: app.onStory));

    if (_erro != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: legenda(_erro!)));
    }
    if (s.isVideo) {
      final v = _video;
      if (v == null || !v.value.isInitialized) {
        return Center(child: CircularProgressIndicator(color: app.onStory));
      }
      return Center(
          child: AspectRatio(
              aspectRatio: v.value.aspectRatio, child: VideoPlayer(v)));
    }

    final rodape = (s.texto != null && s.texto!.isNotEmpty)
        ? Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                color: app.storyBackground
                    .withValues(alpha: AppTheme.opacityOverlay),
                child: legenda(s.texto!),
              ),
            ),
          )
        : null;

    if (s.temMidia) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: s.midiaUrl!,
            fit: BoxFit.contain,
            placeholder: (c, u) =>
                Center(child: CircularProgressIndicator(color: app.onStory)),
            errorWidget: (c, u, e) =>
                Center(child: legenda('Não foi possível carregar a imagem.')),
          ),
          ?rodape,
        ],
      );
    }

    return ColoredBox(
      color: AppTheme.fromHex(s.cor, colors.primary),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.vaccines_rounded,
                  color: app.onStory, size: AppTheme.iconXl),
              const SizedBox(height: AppTheme.spacingLg),
              Text(s.titulo,
                  textAlign: TextAlign.center,
                  style: text.headlineMedium?.copyWith(color: app.onStory)),
              if (s.texto != null && s.texto!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMd),
                legenda(s.texto!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
