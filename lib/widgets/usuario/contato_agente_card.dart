import 'package:flutter/material.dart';

import '../../models/agente_contato.dart';
import '../../theme/theme.dart';
import '../common/info_linha.dart';

class ContatoAgenteCard extends StatelessWidget {
  const ContatoAgenteCard({
    super.key,
    required this.contato,
    required this.onLigar,
    required this.onWhatsApp,
  });

  final AgenteContato contato;
  final ValueChanged<String> onLigar;
  final ValueChanged<String> onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = contato;
    const falta = 'Não informado';
    final tel = c.telefone;
    final zap = c.whatsapp ?? c.telefone;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(c.nome, style: text.headlineSmall),
            Text('Agente comunitário de saúde', style: text.bodyMedium),
            const Divider(),
            InfoLinha(rotulo: 'Área de atuação', valor: c.area ?? falta),
            InfoLinha(rotulo: 'Telefone', valor: tel ?? falta),
            InfoLinha(rotulo: 'WhatsApp', valor: c.whatsapp ?? falta),
            InfoLinha(rotulo: 'Dias de atendimento', valor: c.dias ?? falta),
            InfoLinha(rotulo: 'Horários de atendimento', valor: c.horarios ?? falta),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: tel == null ? null : () => onLigar(tel),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: zap == null ? null : () => onWhatsApp(zap),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
