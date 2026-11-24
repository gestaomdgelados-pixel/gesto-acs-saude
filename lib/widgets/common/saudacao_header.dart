import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SaudacaoHeader extends StatelessWidget {
  const SaudacaoHeader({super.key, required this.nome, required this.perfil});

  final String nome;
  final String perfil;

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final primeiro = nome.trim().split(' ').first;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [app.brandStart, app.brandEnd],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, $primeiro!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.headlineSmall?.copyWith(color: app.onBrand)),
                const SizedBox(height: AppTheme.spacingXs),
                Text(perfil,
                    style: text.bodyMedium?.copyWith(color: app.onBrand)),
              ],
            ),
          ),
          Icon(Icons.health_and_safety_rounded,
              color: app.onBrand, size: AppTheme.iconXl),
        ],
      ),
    );
  }
}
