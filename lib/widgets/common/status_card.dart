import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';

/// Cartão grande de um status, estilo WhatsApp: borda colorida enquanto é novo.
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.story,
    required this.onTap,
    this.visto = false,
  });

  final Story story;
  final VoidCallback onTap;
  final bool visto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final app = theme.extension<AppColorsExtension>()!;

    Widget icone(IconData i) => Container(
          color: app.storyBackground,
          alignment: Alignment.center,
          child: Icon(i, color: app.onStory, size: AppTheme.iconXl),
        );

    final Widget previa;
    if (story.temMidia && !story.isVideo) {
      previa = Image.network(
        story.midiaUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => icone(Icons.image_rounded),
      );
    } else if (story.temMidia) {
      previa = icone(Icons.play_circle_fill_rounded);
    } else {
      previa = Container(
        color: colors.primary,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        alignment: Alignment.center,
        child: Text(
          story.texto ?? story.titulo,
          textAlign: TextAlign.center,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium
              ?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w700),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: visto ? colors.outlineVariant : colors.primary,
          width: visto ? AppTheme.borderDefault : AppTheme.borderThick,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: previa),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Icon(
                          visto ? Icons.done_all_rounded : Icons.fiber_new_rounded,
                          size: AppTheme.iconSm,
                          color: visto ? app.subtleText : colors.primary),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(visto ? 'Visto' : 'Novo',
                          style: text.labelMedium?.copyWith(
                              color: visto ? app.subtleText : colors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
