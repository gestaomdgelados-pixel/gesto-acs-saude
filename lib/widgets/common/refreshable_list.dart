import 'package:flutter/material.dart';

import '../../theme/responsive_layout.dart';
import '../../theme/theme.dart';

class RefreshableList extends StatelessWidget {
  const RefreshableList(
      {super.key, required this.onRefresh, required this.children});

  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveLayout.getPadding(context)
            .copyWith(bottom: AppTheme.fabClearance),
        children: [
          ResponsiveLayout.constrain(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
