import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AvisoCard extends StatelessWidget {
  const AvisoCard({
    super.key,
    required this.titulo,
    required this.rotulo,
    required this.icone,
    this.descricao,
    this.data,
    this.onTap,
    this.onExcluir,
  });

  final String titulo;
  final String rotulo;
  final IconData icone;
  final String? descricao;
  final String? data;
  final VoidCallback? onTap;
  final VoidCallback? onExcluir;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppTheme.avatarMd,
                height: AppTheme.avatarMd,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icone, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rotulo.toUpperCase(),
                        style: text.labelSmall?.copyWith(
                            color: colors.primary, fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    if (descricao != null && descricao!.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(descricao!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium),
                    ],
                    if (data != null) ...[
                      const SizedBox(height: AppTheme.spacingSm),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: AppTheme.iconSm, color: app.subtleText),
                          const SizedBox(width: AppTheme.spacingXs),
                          Flexible(
                            child: Text(data!,
                                style: text.bodySmall
                                    ?.copyWith(color: app.subtleText)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  tooltip: 'Excluir',
                  icon: Icon(Icons.delete_outline_rounded, color: app.danger),
                  onPressed: onExcluir,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
