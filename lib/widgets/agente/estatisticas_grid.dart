import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/status_chip.dart';

class EstatisticaItem {
  const EstatisticaItem({
    required this.icone,
    required this.valor,
    required this.rotulo,
    this.tom = StatusTom.neutro,
  });

  final IconData icone;
  final int valor;
  final String rotulo;
  final StatusTom tom;
}

class EstatisticasGrid extends StatelessWidget {
  const EstatisticasGrid({super.key, required this.itens});

  final List<EstatisticaItem> itens;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itens.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: EstatisticaCard(item: itens[i])),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: i + 1 < itens.length
                        ? EstatisticaCard(item: itens[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class EstatisticaCard extends StatelessWidget {
  const EstatisticaCard({super.key, required this.item});

  final EstatisticaItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final (fundo, frente) = switch (item.tom) {
      StatusTom.aviso => (app.warning, app.onWarning),
      StatusTom.sucesso => (app.success, app.onSuccess),
      StatusTom.perigo => (app.danger, app.onDanger),
      StatusTom.neutro => (colors.primaryContainer, colors.onPrimaryContainer),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              width: AppTheme.avatarMd,
              height: AppTheme.avatarMd,
              decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
              child: Icon(item.icone, color: frente),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${item.valor}', style: text.headlineSmall),
                  Text(
                    item.rotulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: app.subtleText),
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
