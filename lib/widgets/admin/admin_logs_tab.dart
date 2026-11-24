import 'package:flutter/material.dart';

import '../../models/log_entry.dart';
import '../../theme/theme.dart';
import '../common/async_section.dart';
import '../common/formatos.dart';
import '../common/refreshable_list.dart';
import '../common/section_header.dart';

class AdminLogsTab extends StatelessWidget {
  const AdminLogsTab({
    super.key,
    required this.logs,
    required this.carregando,
    required this.erro,
    required this.nomeDe,
    required this.onAtualizar,
  });

  final List<LogEntry> logs;
  final bool carregando;
  final String? erro;
  final String Function(String? id) nomeDe;
  final Future<void> Function() onAtualizar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    return RefreshableList(
      onRefresh: onAtualizar,
      children: [
        const SectionHeader(
            titulo: 'Registro de alterações', icone: Icons.history_rounded),
        AsyncSection(
          carregando: carregando,
          erro: erro,
          vazio: logs.isEmpty,
          textoVazio: 'Nenhum registro ainda.',
          onTentarNovamente: onAtualizar,
          child: Card(
            child: Column(
              children: [
                for (final l in logs)
                  ListTile(
                    leading: const Icon(Icons.edit_note_rounded),
                    title: Text(l.acao.replaceAll('_', ' ')),
                    subtitle: Text(
                      [
                        if (l.detalhe != null) l.detalhe!,
                        'por ${nomeDe(l.usuarioId)}',
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: l.criadoEm == null
                        ? null
                        : Text(dataHora(l.criadoEm!),
                            style:
                                text.bodySmall?.copyWith(color: app.subtleText)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
