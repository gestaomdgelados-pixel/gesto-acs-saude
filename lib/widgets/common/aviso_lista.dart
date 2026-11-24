import 'package:flutter/material.dart';

import '../../models/aviso.dart';
import '../../theme/theme.dart';
import 'aviso_card.dart';
import 'formatos.dart';

class AvisoLista extends StatelessWidget {
  const AvisoLista({super.key, required this.avisos, this.onExcluir});

  final List<Aviso> avisos;
  final ValueChanged<Aviso>? onExcluir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in avisos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: AvisoCard(
              titulo: a.titulo,
              rotulo: a.isReuniao ? 'Reunião' : 'Aviso da gestão',
              icone: a.isReuniao
                  ? Icons.groups_rounded
                  : Icons.notifications_active_rounded,
              descricao: a.descricao,
              data: a.isReuniao ? dataExtensa(a.data) : dataCurta(a.data),
              onExcluir: onExcluir == null ? null : () => onExcluir!(a),
            ),
          ),
      ],
    );
  }
}
