import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar({
    super.key,
    required this.total,
    required this.indice,
    required this.animacao,
  });

  final int total;
  final int indice;
  final Animation<double> animacao;

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    return AnimatedBuilder(
      animation: animacao,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs / 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.progressHeight),
                  child: LinearProgressIndicator(
                    minHeight: AppTheme.progressHeight,
                    value: i < indice ? 1 : (i == indice ? animacao.value : 0),
                    color: app.onStory,
                    backgroundColor:
                        app.onStory.withValues(alpha: AppTheme.opacityTrack),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
