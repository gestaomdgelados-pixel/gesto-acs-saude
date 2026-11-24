import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';

class PropagandaCard extends StatelessWidget {
  const PropagandaCard({super.key, required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final fundo = AppTheme.fromHex(story.cor, colors.primary);

    final Widget icone = Center(
      child: Icon(
        story.isVideo ? Icons.play_circle_fill_rounded : Icons.campaign_rounded,
        color: app.onStory,
        size: AppTheme.iconXl,
      ),
    );

    final Widget base = story.temMidia && !story.isVideo
        ? CachedNetworkImage(
            imageUrl: story.midiaUrl!,
            fit: BoxFit.cover,
            placeholder: (c, u) =>
                ColoredBox(color: colors.surfaceContainerHighest),
            errorWidget: (c, u, e) => ColoredBox(color: fundo, child: icone),
          )
        : ColoredBox(color: story.isVideo ? app.storyBackground : fundo, child: icone);

    return Semantics(
      button: true,
      label: 'Propaganda: ${story.titulo}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            base,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                color: app.storyBackground.withValues(alpha: AppTheme.opacityOverlay),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(story.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(color: app.onStory)),
                    if (story.texto != null && story.texto!.isNotEmpty)
                      Text(story.texto!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(color: app.onStory)),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
