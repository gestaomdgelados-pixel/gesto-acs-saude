import 'package:flutter/material.dart';

import '../../models/vacina.dart';
import '../../theme/theme.dart';
import '../common/formatos.dart';

enum AcaoVacina { agendar, concluir, excluir }

class VacinaItemTile extends StatelessWidget {
  const VacinaItemTile({super.key, required this.item, required this.onAcao});

  final VacinaItem item;
  final ValueChanged<AcaoVacina> onAcao;

  String _detalhe() {
    final r = item.registro;
    if (r == null) return 'Ainda não agendada';
    if (item.concluida) {
      final dia = r.aplicadaEm;
      final quem = r.aplicadoPor;
      final lote = r.lote;
      return [
        if (dia != null) 'Aplicada em ${dataCurta(dia)}',
        if (quem != null && quem.isNotEmpty) 'por $quem',
        if (lote != null && lote.isNotEmpty) 'lote $lote',
      ].join(' · ');
    }
    final prevista = r.dataPrevista;
    return prevista == null ? 'Agendada' : 'Agendada para ${dataCurta(prevista)}';
  }

  @override
  Widget build(BuildContext context) {
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final colors = Theme.of(context).colorScheme;
    final (icone, cor) = item.concluida
        ? (Icons.check_circle_rounded, app.success)
        : item.agendada
            ? (Icons.event_available_rounded, colors.primary)
            : (Icons.vaccines_rounded, app.subtleText);
    return ListTile(
      leading: Icon(icone, color: cor),
      title: Text(item.tipo.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(_detalhe(), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<AcaoVacina>(
        tooltip: 'Ações da vacina',
        onSelected: onAcao,
        itemBuilder: (_) => [
          if (!item.concluida) ...[
            PopupMenuItem(
              value: AcaoVacina.agendar,
              child: Text(item.agendada ? 'Reagendar' : 'Agendar'),
            ),
            const PopupMenuItem(
                value: AcaoVacina.concluir, child: Text('Concluir (aplicada)')),
          ],
          if (item.registro != null)
            PopupMenuItem(
              value: AcaoVacina.excluir,
              child: Text(item.concluida ? 'Excluir registro' : 'Excluir agendamento'),
            ),
        ],
      ),
    );
  }
}
