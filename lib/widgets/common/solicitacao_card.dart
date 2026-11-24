import 'package:flutter/material.dart';

import '../../models/solicitacao.dart';
import '../../theme/theme.dart';
import 'formatos.dart';
import 'status_chip.dart';

class SolicitacaoCard extends StatelessWidget {
  const SolicitacaoCard({super.key, required this.solicitacao, this.acoes});

  final Solicitacao solicitacao;
  final Widget? acoes;

  (String, StatusTom) get _status => switch (solicitacao.status) {
        StatusSolicitacao.pendente => ('Aguardando gestão', StatusTom.aviso),
        StatusSolicitacao.agendada => (
            solicitacao.isConsulta ? 'Agendada' : 'Aceita',
            StatusTom.sucesso
          ),
        StatusSolicitacao.recusada => ('Recusada', StatusTom.perigo),
        StatusSolicitacao.outro => (solicitacao.statusBruto, StatusTom.neutro),
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final s = solicitacao;
    final (rotulo, tom) = _status;
    final icone = switch (s.tipo) {
      'Consulta' => Icons.medical_services_rounded,
      'Reclamação' => Icons.report_rounded,
      _ => Icons.help_center_rounded,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(s.tipo,
                      style: text.labelLarge?.copyWith(color: app.subtleText)),
                ),
                StatusChip(rotulo: rotulo, tom: tom),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(s.assunto,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium),
            if (s.observacao != null && s.observacao!.isNotEmpty)
              Text(s.observacao!, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppTheme.spacingSm),
            if (s.dataDesejada != null)
              Text('Data desejada: ${dataCurta(s.dataDesejada!)}',
                  style: text.bodySmall),
            if (s.dataAgendada != null)
              Text('Agendada para: ${dataHora(s.dataAgendada!)}',
                  style: text.bodyMedium?.copyWith(
                      color: app.success, fontWeight: FontWeight.w700)),
            if (s.motivoRecusa != null && s.motivoRecusa!.isNotEmpty)
              Text('Motivo: ${s.motivoRecusa}',
                  style: text.bodyMedium?.copyWith(color: app.danger)),
            if (s.criadoEm != null)
              Text('Enviada em ${dataHora(s.criadoEm!)}',
                  style: text.bodySmall?.copyWith(color: app.subtleText)),
            if (acoes != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              acoes!,
            ],
          ],
        ),
      ),
    );
  }
}
