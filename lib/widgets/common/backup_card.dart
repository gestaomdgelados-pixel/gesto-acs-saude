import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'error_banner.dart';

class BackupCard extends StatelessWidget {
  const BackupCard({
    super.key,
    required this.ocupado,
    required this.onCriar,
    required this.onUsar,
    this.erro,
    this.sucesso,
  });

  final bool ocupado;
  final VoidCallback onCriar;
  final VoidCallback onUsar;
  final String? erro;
  final String? sucesso;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                'Guarde uma cópia protegida por senha de tudo o que você usa no app. O arquivo fica salvo no seu celular.',
                style: text.bodyLarge),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
                'Sem a senha não é possível abrir o backup. Anote-a em um lugar seguro.',
                style: text.bodyMedium?.copyWith(color: app.subtleText)),
            const SizedBox(height: AppTheme.spacingMd),
            if (ocupado) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            FilledButton.icon(
              onPressed: ocupado ? null : onCriar,
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Fazer backup'),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            OutlinedButton.icon(
              onPressed: ocupado ? null : onUsar,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Usar um backup'),
            ),
            if (erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: erro!),
            ],
            if (sucesso != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Text(sucesso!,
                  style: text.bodyMedium?.copyWith(
                      color: app.success, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}
