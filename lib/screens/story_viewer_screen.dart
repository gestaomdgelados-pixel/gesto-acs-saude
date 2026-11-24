import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/story.dart';
import '../theme/theme.dart';
import '../widgets/story/story_media.dart';
import '../widgets/story/story_progress_bar.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.inicial,
    this.onVisto,
  });

  final List<Story> stories;
  final int inicial;
  final ValueChanged<Story>? onVisto;

  static Future<void> abrir(
      BuildContext context, List<Story> stories, int inicial,
      {ValueChanged<Story>? onVisto}) {
    if (stories.isEmpty) return Future.value();
    return Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => StoryViewerScreen(
          stories: stories, inicial: inicial, onVisto: onVisto),
    ));
  }

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const _duracaoPadrao = Duration(seconds: 6);

  late int _indice = widget.inicial.clamp(0, widget.stories.length - 1);
  bool _pausado = false;
  bool _videoFalhou = false;
  late final AnimationController _progresso =
      AnimationController(vsync: this, duration: _duracaoPadrao)
        ..addStatusListener((s) {
          // Imagem: passa ao fim do tempo. Vídeo: passa quando o vídeo termina.
          if (s == AnimationStatus.completed &&
              (!_atual.isVideo || _videoFalhou)) {
            _proximo();
          }
        });

  Story get _atual => widget.stories[_indice];

  @override
  void initState() {
    super.initState();
    _iniciarAtual();
  }

  void _iniciarAtual() {
    _videoFalhou = false;
    _pausado = false;
    _progresso
      ..stop()
      ..duration = _duracaoPadrao
      ..reset();
    if (!_atual.isVideo) _progresso.forward();
    final s = _atual;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisto?.call(s);
    });
  }

  void _videoPronto(Duration d) {
    if (!mounted) return;
    _progresso.duration = d > Duration.zero ? d : _duracaoPadrao;
    _progresso.reset();
    if (!_pausado) _progresso.forward();
  }

  void _videoErro() {
    _videoFalhou = true;
    _progresso.forward(from: 0);
  }

  void _proximo() {
    if (!mounted) return;
    if (_indice >= widget.stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _indice++);
    _iniciarAtual();
  }

  void _anterior() {
    if (_indice > 0) setState(() => _indice--);
    _iniciarAtual();
  }

  void _pausar(bool pausar) {
    setState(() => _pausado = pausar);
    pausar ? _progresso.stop() : _progresso.forward();
  }

  @override
  void dispose() {
    _progresso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final largura = MediaQuery.sizeOf(context).width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: app.storyBackground,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) =>
              d.localPosition.dx < largura / 2 ? _anterior() : _proximo(),
          onLongPressStart: (_) => _pausar(true),
          onLongPressEnd: (_) => _pausar(false),
          child: Stack(
            children: [
              Positioned.fill(
                child: StoryMedia(
                  key: ValueKey('${_atual.id}-$_indice'),
                  story: _atual,
                  pausado: _pausado,
                  onVideoPronto: _videoPronto,
                  onVideoErro: _videoErro,
                  onVideoFim: _proximo,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    child: Column(
                      children: [
                        StoryProgressBar(
                          total: widget.stories.length,
                          indice: _indice,
                          animacao: _progresso,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _atual.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleMedium
                                    ?.copyWith(color: app.onStory),
                              ),
                            ),
                            if (_pausado)
                              Icon(Icons.pause_rounded, color: app.onStory),
                            IconButton(
                              tooltip: 'Fechar',
                              color: app.onStory,
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
