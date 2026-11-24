import 'package:flutter/material.dart';

import '../../models/estado_envio.dart';
import '../../theme/theme.dart';

class EstadoEnvioChip extends StatelessWidget {
  const EstadoEnvioChip({super.key, required this.estado, this.prefixo});

  final EstadoEnvio estado;
  final String? prefixo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = theme.extension<AppColorsExtension>()!;
    final (rotulo, icone, cor) = switch (estado) {
      EstadoEnvio.enviado => ('Enviado', Icons.check_rounded, app.subtleText),
      EstadoEnvio.recebido =>
        ('Recebido', Icons.done_all_rounded, app.subtleText),
      EstadoEnvio.visto =>
        ('Visto', Icons.done_all_rounded, theme.colorScheme.primary),
    };
    final texto = prefixo == null ? rotulo : '$prefixo: $rotulo';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: AppTheme.iconSm, color: cor),
        const SizedBox(width: AppTheme.spacingXs),
        Flexible(
          child: Text(texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: cor, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
