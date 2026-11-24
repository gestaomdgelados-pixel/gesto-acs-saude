import 'package:flutter/material.dart';

import '../../models/consulta.dart';
import '../../theme/theme.dart';

class ConsultaAcoes extends StatelessWidget {
  const ConsultaAcoes({
    super.key,
    required this.consulta,
    required this.modo,
    required this.souSolicitante,
    required this.onCancelar,
    required this.onAceitar,
    required this.onEncaminhar,
  });

  final Consulta consulta;
  final ModoConsultas modo;
  final bool souSolicitante;
  final VoidCallback onCancelar;
  final VoidCallback onAceitar;
  final VoidCallback onEncaminhar;

  @override
  Widget build(BuildContext context) {
    final cancelar = OutlinedButton.icon(
      onPressed: onCancelar,
      icon: const Icon(Icons.close_rounded),
      label: const Text('Cancelar pedido'),
    );
    return switch (modo) {
      ModoConsultas.gestao => Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: onCancelar, child: const Text('Cancelar')),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: FilledButton(
                  onPressed: onAceitar, child: const Text('Aceitar')),
            ),
          ],
        ),
      ModoConsultas.agente => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onEncaminhar,
              icon: const Icon(Icons.forward_to_inbox_rounded),
              label: Text(consulta.gestorId == null
                  ? 'Encaminhar à gestão'
                  : 'Reencaminhar'),
            ),
            if (souSolicitante) ...[
              const SizedBox(height: AppTheme.spacingSm),
              cancelar,
            ],
          ],
        ),
      ModoConsultas.usuario => cancelar,
    };
  }
}
