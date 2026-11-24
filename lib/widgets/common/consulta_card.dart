import 'package:flutter/material.dart';

import '../../models/consulta.dart';
import '../../models/estado_envio.dart';
import '../../theme/theme.dart';
import 'estado_envio_chip.dart';
import 'formatos.dart';
import 'status_chip.dart';

class ConsultaCard extends StatelessWidget {
  const ConsultaCard({
    super.key,
    required this.consulta,
    required this.nomeAgente,
    this.estado,
    this.estadoPrefixo,
    this.onTap,
    this.acoes,
  });

  final Consulta consulta;
  final String nomeAgente;
  final EstadoEnvio? estado;
  final String? estadoPrefixo;
  final VoidCallback? onTap;
  final Widget? acoes;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final c = consulta;
    final envio = estado;
    final sutil = text.bodyMedium?.copyWith(color: app.subtleText);
    final (rotulo, tom) = switch (c.status) {
      StatusConsulta.solicitada => ('Solicitada', StatusTom.aviso),
      StatusConsulta.aceita => ('Aceita', StatusTom.sucesso),
      StatusConsulta.cancelada => ('Cancelada', StatusTom.perigo),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(c.especialidade,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                  ),
                  StatusChip(rotulo: rotulo, tom: tom),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text('Paciente: ${c.paciente}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge),
              Text('Agente: $nomeAgente',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: sutil),
              if (c.gestorId != null)
                Text('Encaminhada para: @${c.gestorUsuario ?? 'gestão'}',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: sutil)
              else if (c.aguardandoEncaminhar)
                Text('Ainda não encaminhada à gestão', style: sutil),
              if (c.observacao != null && c.observacao!.isNotEmpty)
                Text(c.observacao!,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              if (c.dataMarcada != null)
                Text('Marcada para: ${dataHora(c.dataMarcada!)}',
                    style: text.bodyMedium?.copyWith(
                        color: app.success, fontWeight: FontWeight.w700)),
              if (c.motivo != null && c.motivo!.isNotEmpty)
                Text('Motivo: ${c.motivo}',
                    style: text.bodyMedium?.copyWith(color: app.danger)),
              if (c.criadoEm != null)
                Text('Pedido em ${dataHora(c.criadoEm!)}',
                    style: text.bodySmall?.copyWith(color: app.subtleText)),
              if (envio != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                EstadoEnvioChip(estado: envio, prefixo: estadoPrefixo),
              ],
              if (acoes != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                acoes!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
