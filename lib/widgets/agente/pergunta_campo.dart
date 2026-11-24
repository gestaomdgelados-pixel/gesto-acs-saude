import 'package:flutter/material.dart';

import '../../models/questionario_visita.dart';
import '../../theme/theme.dart';

class PerguntaCampo extends StatelessWidget {
  const PerguntaCampo({
    super.key,
    required this.pergunta,
    required this.onChanged,
  });

  final Pergunta pergunta;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = pergunta;
    final escolha = p.tipo == TipoPergunta.escolha;
    String? validar(String? v) =>
        p.obrigatoria && (v == null || v.trim().isEmpty) ? 'Resposta obrigatória' : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.obrigatoria ? '${p.titulo} *' : p.titulo,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppTheme.spacingXs),
          if (escolha)
            DropdownButtonFormField<String>(
              isExpanded: true,
              hint: const Text('Selecione'),
              items: [
                for (final o in p.opcoes)
                  DropdownMenuItem(
                    value: o,
                    child: Text(o, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => onChanged(v ?? ''),
              validator: validar,
            )
          else
            TextFormField(
              minLines: 2,
              maxLines: 5,
              onChanged: onChanged,
              validator: validar,
            ),
        ],
      ),
    );
  }
}
