import 'package:flutter/material.dart';

import '../../models/questionario_visita.dart';
import '../../models/visita.dart';
import '../../theme/theme.dart';
import '../common/formatos.dart';
import '../common/info_linha.dart';
import '../common/status_chip.dart';

class VisitaTile extends StatelessWidget {
  const VisitaTile({
    super.key,
    required this.visita,
    required this.familia,
    this.onConcluir,
    this.onJustificar,
  });

  final Visita visita;
  final String familia;
  final VoidCallback? onConcluir;
  final VoidCallback? onJustificar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final v = visita;
    final (rotulo, tom) = switch (v.status) {
      StatusVisita.concluida => ('Concluída', StatusTom.sucesso),
      StatusVisita.naoRealizada => v.canceladaPeloMorador
          ? ('Cancelada pelo morador', StatusTom.perigo)
          : ('Não realizada', StatusTom.neutro),
      StatusVisita.agendada =>
        v.atrasada ? ('Atrasada', StatusTom.perigo) : ('Agendada', StatusTom.aviso),
    };
    final respondidas = [
      for (final p in QuestionarioVisita.perguntas)
        if ((v.respostas[p.id] ?? '').trim().isNotEmpty) p,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(familia,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  StatusChip(rotulo: rotulo, tom: tom),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(dataExtensa(v.agendadaPara),
                  style: text.bodyMedium?.copyWith(color: app.subtleText)),
              const SizedBox(height: AppTheme.spacingXs),
              Text(v.motivo, style: text.bodyMedium),
              if (v.status == StatusVisita.naoRealizada)
                InfoLinha(rotulo: 'Justificativa', valor: v.justificativa ?? ''),
              if (v.status == StatusVisita.agendada) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onConcluir,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Concluir'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onJustificar,
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Justificar'),
                      ),
                    ),
                  ],
                ),
              ],
              if (v.status == StatusVisita.concluida && respondidas.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: const Text('Ver questionário'),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in respondidas)
                      InfoLinha(rotulo: p.titulo, valor: v.respostas[p.id] ?? ''),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
