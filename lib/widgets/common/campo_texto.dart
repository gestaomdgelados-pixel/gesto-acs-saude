import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controller,
    required this.rotulo,
    this.obrigatorio = false,
    this.teclado,
    this.linhas = 1,
  });

  final TextEditingController controller;
  final String rotulo;
  final bool obrigatorio;
  final TextInputType? teclado;
  final int linhas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        minLines: linhas,
        maxLines: linhas == 1 ? 1 : linhas + 3,
        decoration: InputDecoration(labelText: obrigatorio ? '$rotulo *' : rotulo),
        validator: obrigatorio
            ? (v) => (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null
            : null,
      ),
    );
  }
}
