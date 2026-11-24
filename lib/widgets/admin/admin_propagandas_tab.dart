import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';
import '../common/async_section.dart';
import '../common/formatos.dart';
import '../common/refreshable_list.dart';
import '../common/section_header.dart';

class AdminPropagandasTab extends StatelessWidget {
  const AdminPropagandasTab({
    super.key,
    required this.stories,
    required this.carregando,
    required this.erro,
    required this.onAtualizar,
    required this.onAbrir,
    required this.onAlterarAtivo,
    required this.onExcluir,
  });

  final List<Story> stories;
  final bool carregando;
  final String? erro;
  final Future<void> Function() onAtualizar;
  final ValueChanged<Story> onAbrir;
  final void Function(Story s, bool ativo) onAlterarAtivo;
  final ValueChanged<Story> onExcluir;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;

    return RefreshableList(
      onRefresh: onAtualizar,
      children: [
        const SectionHeader(
            titulo: 'Propagandas para todos os logins',
            icone: Icons.campaign_rounded),
        AsyncSection(
          carregando: carregando,
          erro: erro,
          vazio: stories.isEmpty,
          textoVazio: 'Nenhuma propaganda. Toque em "Nova propaganda".',
          onTentarNovamente: onAtualizar,
          child: Column(
            children: [
              for (final s in stories)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () => onAbrir(s),
                      leading: CircleAvatar(
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                        child: Icon(s.isVideo
                            ? Icons.videocam_rounded
                            : (s.temMidia
                                ? Icons.image_rounded
                                : Icons.vaccines_rounded)),
                      ),
                      title: Text(s.titulo,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${s.ativo ? 'Ativa' : 'Pausada'}'
                        '${s.criadoEm == null ? '' : ' · ${dataCurta(s.criadoEm!)}'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: s.ativo,
                            onChanged: (v) => onAlterarAtivo(s, v),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: Icon(Icons.delete_outline_rounded,
                                color: app.danger),
                            onPressed: () => onExcluir(s),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
