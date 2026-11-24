import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class InfoLinha extends StatelessWidget {
  const InfoLinha({super.key, required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: text.labelMedium?.copyWith(color: app.subtleText)),
          Text(valor, style: text.bodyMedium),
        ],
      ),
    );
  }
}
