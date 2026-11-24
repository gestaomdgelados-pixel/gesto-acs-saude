import 'package:flutter/material.dart';

import '../../models/aviso.dart';
import '../../theme/theme.dart';
import 'error_banner.dart';
import 'formatos.dart';

/// Quadro grande, com letra maior, para os avisos e reuniões da gestão.
class AvisosDestaque extends StatelessWidget {
  const AvisosDestaque({
    super.key,
    required this.avisos,
    required this.carregando,
    required this.erro,
    required this.onTentarNovamente,
  });

  final List<Aviso> avisos;
  final bool carregando;
  final String? erro;
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final cor = colors.onPrimaryContainer;

    Widget conteudo;
    if (carregando && avisos.isEmpty) {
      conteudo = const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLg),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (erro != null) {
      conteudo = ErrorBanner(mensagem: erro!, onTentarNovamente: onTentarNovamente);
    } else if (avisos.isEmpty) {
      conteudo = Text('Nenhum aviso da gestão no momento.',
          style: text.titleMedium?.copyWith(color: cor));
    } else {
      conteudo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < avisos.length; i++) ...[
            if (i > 0) Divider(color: cor, height: AppTheme.spacingLg * 2),
            Text(
              '${avisos[i].isReuniao ? 'Reunião' : 'Aviso'} · ${dataCurta(avisos[i].data)}',
              style: text.labelLarge?.copyWith(color: cor),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(avisos[i].titulo,
                style: text.headlineSmall
                    ?.copyWith(color: cor, fontWeight: FontWeight.w800)),
            if ((avisos[i].descricao ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(avisos[i].descricao!,
                  style: text.titleMedium?.copyWith(color: cor)),
            ],
          ],
        ],
      );
    }

    return Card(
      color: colors.primaryContainer,
      margin: const EdgeInsets.only(top: AppTheme.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, color: cor),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text('Avisos da gestão',
                      style: text.titleLarge
                          ?.copyWith(color: cor, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            conteudo,
          ],
        ),
      ),
    );
  }
}
