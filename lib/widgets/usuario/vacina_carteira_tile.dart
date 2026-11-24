import 'package:flutter/material.dart';

import '../../models/carteira.dart';
import '../../models/vacina.dart';
import '../../theme/theme.dart';
import '../common/formatos.dart';
import '../common/status_chip.dart';

class VacinaCarteiraTile extends StatelessWidget {
  const VacinaCarteiraTile({super.key, required this.item});

  final VacinaItem item;

  String _detalhe() {
    final r = item.registro;
    switch (item.situacao) {
      case SituacaoVacina.concluida:
        final d = r?.aplicadaEm;
        return [
          if (d != null) 'Aplicada em ${dataCurta(d)}',
          if ((r?.lote ?? '').isNotEmpty) 'Lote ${r!.lote}',
          if ((r?.aplicadoPor ?? '').isNotEmpty) 'por ${r!.aplicadoPor}',
        ].join(' · ');
      case SituacaoVacina.agendada:
      case SituacaoVacina.atrasada:
        final d = r?.dataPrevista;
        return d == null ? 'Agendada pelo agente' : 'Agendada para ${dataCurta(d)}';
      case SituacaoVacina.pendente:
        return 'Ainda não agendada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final s = item.situacao;
    final tom = switch (s) {
      SituacaoVacina.concluida => StatusTom.sucesso,
      SituacaoVacina.agendada => StatusTom.aviso,
      SituacaoVacina.atrasada => StatusTom.perigo,
      SituacaoVacina.pendente => StatusTom.neutro,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tipo.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge),
                Text(_detalhe(),
                    style: text.bodySmall?.copyWith(color: app.subtleText)),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          StatusChip(rotulo: s.rotulo, tom: tom),
        ],
      ),
    );
  }
}
