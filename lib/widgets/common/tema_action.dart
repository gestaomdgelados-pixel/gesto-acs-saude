import 'package:flutter/material.dart';

class TemaAction extends StatelessWidget {
  const TemaAction({super.key, required this.onAlternar});

  final VoidCallback onAlternar;

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: escuro ? 'Tema claro' : 'Tema escuro',
      icon: Icon(escuro ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: onAlternar,
    );
  }
}
