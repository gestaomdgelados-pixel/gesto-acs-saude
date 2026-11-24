import 'package:flutter/material.dart';

import '../../models/familia.dart';
import '../../theme/theme.dart';
import '../common/info_linha.dart';

class FamiliaResumoCard extends StatelessWidget {
  const FamiliaResumoCard({super.key, required this.familia});

  final Familia familia;

  @override
  Widget build(BuildContext context) {
    final f = familia;
    final linhas = <(String, String?)>[
      ('Endereço', f.endereco),
      ('Telefone', f.telefone),
      ('Complemento', f.complemento),
      ('Microárea', f.microarea),
      ('Moradia', f.moradia),
      ('Abastecimento de água', f.agua),
      ('Esgoto', f.esgoto),
      ('Lixo', f.lixo),
      ('Renda familiar', f.renda),
      ('Energia elétrica', f.energia ? 'Sim' : 'Não'),
      ('Animais em casa', f.animais ? 'Sim' : 'Não'),
      ('Observações', f.observacao),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (rotulo, valor) in linhas)
              if (valor != null && valor.isNotEmpty)
                InfoLinha(rotulo: rotulo, valor: valor),
          ],
        ),
      ),
    );
  }
}
