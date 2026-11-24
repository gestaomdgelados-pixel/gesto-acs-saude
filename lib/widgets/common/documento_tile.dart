import 'package:flutter/material.dart';

import '../../models/documento.dart';
import '../../theme/theme.dart';
import 'estado_envio_chip.dart';
import 'formatos.dart';
import 'status_chip.dart';

class DocumentoTile extends StatelessWidget {
  const DocumentoTile({
    super.key,
    required this.documento,
    required this.recebido,
    required this.onAbrir,
  });

  final Documento documento;
  final bool recebido;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final d = documento;
    final colors = Theme.of(context).colorScheme;
    final quem = recebido
        ? 'De: ${d.remetenteNome ?? 'Agente de saúde'}'
        : 'Para: @${d.destinatarioUsuario ?? ''}';
    final quando = d.enviadoEm == null ? '' : ' · ${dataHora(d.enviadoEm!)}';
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        leading: Icon(Icons.picture_as_pdf_rounded, color: colors.primary),
        title: Text(d.nomeArquivo,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$quem$quando',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            if (!recebido) EstadoEnvioChip(estado: d.estado),
          ],
        ),
        trailing: recebido && d.vistoEm == null
            ? const StatusChip(rotulo: 'Novo', tom: StatusTom.aviso)
            : const Icon(Icons.open_in_new_rounded),
        onTap: onAbrir,
      ),
    );
  }
}
