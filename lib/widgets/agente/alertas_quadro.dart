import 'package:flutter/material.dart';

import '../../models/alerta_atraso.dart';
import '../../theme/theme.dart';
import '../common/formatos.dart';

/// Quadro em destaque com visitas, vacinas e cadastros em atraso.
class AlertasQuadro extends StatelessWidget {
  const AlertasQuadro({super.key, required this.alertas});

  final List<AlertaAtraso> alertas;

  static IconData _icone(TipoAlerta t) => switch (t) {
        TipoAlerta.visita => Icons.home_work_rounded,
        TipoAlerta.vacina => Icons.vaccines_rounded,
        TipoAlerta.cadastroFamilia => Icons.family_restroom_rounded,
        TipoAlerta.cadastroPessoa => Icons.person_search_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final app = theme.extension<AppColorsExtension>()!;
    final semAtraso = alertas.isEmpty;
    final fundo = semAtraso ? app.success : colors.errorContainer;
    final cor = semAtraso ? app.onSuccess : colors.onErrorContainer;

    return Card(
      color: fundo,
      margin: const EdgeInsets.only(top: AppTheme.spacingLg),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    semAtraso
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: cor),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    semAtraso
                        ? 'Nada em atraso'
                        : 'Em atraso (${alertas.length})',
                    style: text.titleLarge
                        ?.copyWith(color: cor, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            if (semAtraso)
              Text('Visitas, vacinas e cadastros estão em dia.',
                  style: text.bodyLarge?.copyWith(color: cor))
            else
              for (final a in alertas)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_icone(a.tipo), color: cor),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleSmall?.copyWith(
                                    color: cor, fontWeight: FontWeight.w700)),
                            Text(
                              a.desde == null
                                  ? a.detalhe
                                  : '${a.detalhe} · desde ${dataCurta(a.desde!)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(color: cor),
                            ),
                          ],
                        ),
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
