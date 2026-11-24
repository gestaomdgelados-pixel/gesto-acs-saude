import 'package:flutter/material.dart';

import '../../models/visita.dart';
import '../../theme/theme.dart';
import '../common/formatos.dart';
import '../common/info_linha.dart';
import '../common/status_chip.dart';

class VisitaMoradorTile extends StatelessWidget {
  const VisitaMoradorTile({
    super.key,
    required this.visita,
    required this.agente,
    this.onCancelar,
  });

  final Visita visita;
  final String agente;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final v = visita;
    final d = v.agendadaPara;
    final (rotulo, tom) = switch (v.status) {
      StatusVisita.concluida => ('Realizada', StatusTom.sucesso),
      StatusVisita.naoRealizada => v.canceladaPeloMorador
          ? ('Cancelada', StatusTom.perigo)
          : ('Não realizada', StatusTom.neutro),
      StatusVisita.agendada => ('Agendada', StatusTom.aviso),
    };
    final quem = agente.isEmpty ? 'O agente' : 'O agente $agente';

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
                    child: Text('${dataCurta(d)} às ${hora(d)}',
                        style: text.titleMedium),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  StatusChip(rotulo: rotulo, tom: tom),
                ],
              ),
              if (v.status == StatusVisita.agendada) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                    '$quem agendou uma visita para o dia ${dataCurta(d)} às ${hora(d)}.',
                    style: text.bodyMedium),
              ],
              const SizedBox(height: AppTheme.spacingXs),
              Text('Motivo: ${v.motivo}',
                  style: text.bodyMedium?.copyWith(color: app.subtleText)),
              if (v.status == StatusVisita.naoRealizada &&
                  (v.justificativa ?? '').isNotEmpty)
                InfoLinha(rotulo: 'Justificativa', valor: v.justificativa!),
              if (onCancelar != null) ...[
                const SizedBox(height: AppTheme.spacingSm),
                OutlinedButton.icon(
                  onPressed: onCancelar,
                  icon: const Icon(Icons.event_busy_rounded),
                  label: const Text('Cancelar visita'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
