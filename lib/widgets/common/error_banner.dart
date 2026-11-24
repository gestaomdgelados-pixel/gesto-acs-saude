import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.mensagem, this.onTentarNovamente});

  final String mensagem;
  final VoidCallback? onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: colors.onErrorContainer, size: AppTheme.iconMd),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: SelectableText(mensagem,
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onErrorContainer)),
              ),
            ],
          ),
          if (onTentarNovamente != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTentarNovamente,
                icon: Icon(Icons.refresh_rounded, color: colors.onErrorContainer),
                label: Text('Tentar novamente',
                    style: TextStyle(color: colors.onErrorContainer)),
              ),
            ),
        ],
      ),
    );
  }
}
