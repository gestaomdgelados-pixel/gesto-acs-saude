import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum StatusTom { aviso, sucesso, perigo, neutro }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.rotulo, required this.tom});

  final String rotulo;
  final StatusTom tom;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final (fundo, frente) = switch (tom) {
      StatusTom.aviso => (app.warning, app.onWarning),
      StatusTom.sucesso => (app.success, app.onSuccess),
      StatusTom.perigo => (app.danger, app.onDanger),
      StatusTom.neutro => (colors.secondaryContainer, colors.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(rotulo,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: frente, fontWeight: FontWeight.w700)),
    );
  }
}
