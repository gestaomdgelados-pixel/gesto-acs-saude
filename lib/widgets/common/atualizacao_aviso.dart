import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Aviso grande no topo de todos os perfis quando existe versão nova.
class AtualizacaoAviso extends StatelessWidget {
  const AtualizacaoAviso(
      {super.key, required this.versao, required this.onAbrir});

  final String versao;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cor = colors.onTertiaryContainer;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
      child: SingleChildScrollView(
        child: Card(
          color: colors.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.system_update_rounded,
                        color: cor, size: AppTheme.iconLg),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text('Nova versão $versao disponível',
                          style: text.titleMedium?.copyWith(color: cor)),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Faça o backup dos seus dados e instale a nova versão disponível nas configurações.',
                  style: text.headlineSmall
                      ?.copyWith(color: cor, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                FilledButton.icon(
                  onPressed: onAbrir,
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Abrir configurações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
