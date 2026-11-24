import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'error_banner.dart';

class AsyncSection extends StatelessWidget {
  const AsyncSection({
    super.key,
    required this.carregando,
    required this.erro,
    required this.vazio,
    required this.textoVazio,
    required this.onTentarNovamente,
    required this.child,
  });

  final bool carregando;
  final String? erro;
  final bool vazio;
  final String textoVazio;
  final VoidCallback onTentarNovamente;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (erro != null) {
      return ErrorBanner(mensagem: erro!, onTentarNovamente: onTentarNovamente);
    }
    if (carregando && vazio) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingXl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vazio) {
      final app = Theme.of(context).extension<AppColorsExtension>()!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded,
                size: AppTheme.iconLg, color: app.subtleText),
            const SizedBox(height: AppTheme.spacingSm),
            Text(textoVazio,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: app.subtleText)),
          ],
        ),
      );
    }
    return child;
  }
}
