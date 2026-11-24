import 'package:flutter/material.dart';

import '../../models/versao_app.dart';
import '../../theme/theme.dart';

class VersaoCard extends StatelessWidget {
  const VersaoCard({
    super.key,
    required this.instalada,
    required this.ultima,
    required this.temNova,
    required this.podePublicar,
    required this.onPublicar,
    this.onBaixar,
  });

  final String instalada;
  final VersaoApp? ultima;
  final bool temNova;
  final bool podePublicar;
  final VoidCallback onPublicar;
  final VoidCallback? onBaixar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final u = ultima;
    final notas = u?.notas;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Versão instalada: ${instalada.isEmpty ? '—' : instalada}',
                style: text.titleMedium),
            Text('Última versão publicada: ${u?.versao ?? 'nenhuma'}',
                style: text.bodyMedium?.copyWith(color: app.subtleText)),
            if (notas != null && notas.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(notas, style: text.bodyMedium),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            if (temNova)
              FilledButton.icon(
                onPressed: onBaixar,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Baixar e instalar a nova versão'),
              )
            else
              Text('Você está com a versão mais recente.',
                  style: text.bodyMedium?.copyWith(
                      color: app.success, fontWeight: FontWeight.w700)),
            if (podePublicar) ...[
              const SizedBox(height: AppTheme.spacingSm),
              OutlinedButton.icon(
                onPressed: onPublicar,
                icon: const Icon(Icons.publish_rounded),
                label: const Text('Publicar nova versão'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
