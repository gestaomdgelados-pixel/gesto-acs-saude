import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Image.asset(
        'assets/icons/app_icon.png',
        width: AppTheme.logoSize,
        height: AppTheme.logoSize,
        semanticLabel: 'Logo Gestão ACS Saúde',
      ),
    );
  }
}
