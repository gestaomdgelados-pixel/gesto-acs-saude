import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.titulo, required this.icone});

  final String titulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
          top: AppTheme.spacingLg, bottom: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(icone, color: colors.primary, size: AppTheme.iconMd),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
