import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ContatoAdminCard extends StatelessWidget {
  const ContatoAdminCard({
    super.key,
    required this.telefone,
    required this.podeEditar,
    required this.onEditar,
    required this.onLigar,
    required this.onWhatsApp,
  });

  final String? telefone;
  final bool podeEditar;
  final VoidCallback onEditar;
  final ValueChanged<String> onLigar;
  final ValueChanged<String> onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final t = telefone;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                'Precisa mudar algo no seu login? Fale com o administrador.',
                style: text.bodyMedium?.copyWith(color: app.subtleText)),
            const SizedBox(height: AppTheme.spacingSm),
            Text(t ?? 'Número ainda não cadastrado.',
                style: t == null ? text.bodyLarge : text.headlineSmall),
            if (t != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onLigar(t),
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('Ligar'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onWhatsApp(t),
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ),
            ],
            if (podeEditar) ...[
              const SizedBox(height: AppTheme.spacingSm),
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_rounded),
                label: Text(t == null ? 'Cadastrar meu número' : 'Editar meu número'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
