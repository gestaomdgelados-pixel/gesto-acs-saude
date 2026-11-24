import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'app_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        const AppLogo(),
        const SizedBox(height: AppTheme.spacingMd),
        Text('Gestão ACS Saúde',
            textAlign: TextAlign.center,
            style: text.headlineMedium
                ?.copyWith(color: app.onBrand, fontWeight: FontWeight.w900)),
        const SizedBox(height: AppTheme.spacingXs),
        Text('Moradores, agentes e gestão do posto conectados',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: app.onBrand)),
      ],
    );
  }
}
