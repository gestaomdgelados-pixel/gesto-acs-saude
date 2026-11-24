import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class CampoOpcoes extends StatelessWidget {
  const CampoOpcoes({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.valor,
    required this.onChanged,
    this.obrigatorio = false,
  });

  final String rotulo;
  final List<String> opcoes;
  final String? valor;
  final ValueChanged<String?> onChanged;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: DropdownButtonFormField<String>(
        initialValue: opcoes.contains(valor) ? valor : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: obrigatorio ? '$rotulo *' : rotulo),
        items: [
          for (final o in opcoes)
            DropdownMenuItem(
              value: o,
              child: Text(o, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
        validator: obrigatorio ? (v) => v == null ? 'Escolha uma opção' : null : null,
      ),
    );
  }
}
