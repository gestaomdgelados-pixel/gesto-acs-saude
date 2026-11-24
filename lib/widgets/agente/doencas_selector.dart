import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class DoencasSelector extends StatelessWidget {
  const DoencasSelector({
    super.key,
    required this.opcoes,
    required this.selecionadas,
    required this.onChanged,
  });

  final List<String> opcoes;
  final List<String> selecionadas;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Wrap(
        spacing: AppTheme.spacingSm,
        runSpacing: AppTheme.spacingSm,
        children: [
          for (final o in opcoes)
            FilterChip(
              label: Text(o),
              selected: selecionadas.contains(o),
              onSelected: (marcado) {
                final novo = [...selecionadas];
                marcado ? novo.add(o) : novo.remove(o);
                onChanged(novo);
              },
            ),
        ],
      ),
    );
  }
}
