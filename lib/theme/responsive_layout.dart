import 'package:flutter/material.dart';

import 'theme.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static EdgeInsets getPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return const EdgeInsets.all(AppTheme.spacingMd);
    if (w < 1200) return const EdgeInsets.all(AppTheme.spacingLg);
    return const EdgeInsets.all(AppTheme.spacingXl);
  }

  static Widget constrain(Widget child,
      {double maxWidth = AppTheme.contentMaxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
