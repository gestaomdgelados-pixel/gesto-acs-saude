import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';
import 'propaganda_card.dart';

class PropagandaCarousel extends StatefulWidget {
  const PropagandaCarousel(
      {super.key, required this.stories, required this.onAbrir});

  final List<Story> stories;
  final ValueChanged<int> onAbrir;

  @override
  State<PropagandaCarousel> createState() => _PropagandaCarouselState();
}

class _PropagandaCarouselState extends State<PropagandaCarousel> {
  late final PageController _pc = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _atual = 0;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void didUpdateWidget(covariant PropagandaCarousel old) {
    super.didUpdateWidget(old);
    if (old.stories.length != widget.stories.length) {
      _atual = 0;
      if (_pc.hasClients) _pc.jumpToPage(0);
      _iniciar();
    }
  }

  void _iniciar() {
    _timer?.cancel();
    if (widget.stories.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pc.hasClients) return;
      final prox = (_atual + 1) % widget.stories.length;
      if (MediaQuery.disableAnimationsOf(context)) {
        _pc.jumpToPage(prox);
      } else {
        _pc.animateToPage(prox,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: AppTheme.propagandaHeight,
          child: PageView.builder(
            controller: _pc,
            itemCount: widget.stories.length,
            onPageChanged: (i) => setState(() => _atual = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              child: PropagandaCard(
                story: widget.stories[i],
                onTap: () => widget.onAbrir(i),
              ),
            ),
          ),
        ),
        if (widget.stories.length > 1) ...[
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.stories.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs / 2),
                  width: i == _atual ? AppTheme.dotActiveWidth : AppTheme.dotSize,
                  height: AppTheme.dotSize,
                  decoration: BoxDecoration(
                    color: i == _atual ? colors.primary : colors.outlineVariant,
                    borderRadius: BorderRadius.circular(AppTheme.dotSize),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
