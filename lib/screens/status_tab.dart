import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stories_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/async_section.dart';
import '../widgets/common/error_banner.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/status_card.dart';
import 'story_viewer_screen.dart';

/// Status da gestão em cartões grandes (gestão, agente e usuário).
class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = context.watch<StoriesProvider>();
    final todos = stories.ativos;
    // Os novos aparecem primeiro, como no WhatsApp.
    final ativos = [
      ...todos.where((s) => !stories.foiVisto(s)),
      ...todos.where(stories.foiVisto),
    ];
    final erroVistos = stories.erroVistos;

    return RefreshableList(
      onRefresh: stories.carregar,
      children: [
        const SectionHeader(
            titulo: 'Status da gestão', icone: Icons.amp_stories_rounded),
        if (erroVistos != null) ...[
          ErrorBanner(mensagem: erroVistos),
          const SizedBox(height: AppTheme.spacingSm),
        ],
        AsyncSection(
          carregando: stories.carregando,
          erro: stories.erro,
          vazio: ativos.isEmpty,
          textoVazio: 'Nenhum status publicado no momento.',
          onTentarNovamente: stories.carregar,
          child: LayoutBuilder(
            builder: (context, c) {
              final colunas = c.maxWidth < 600 ? 2 : 4;
              const gap = AppTheme.spacingMd;
              final largura = (c.maxWidth - gap * (colunas - 1)) / colunas;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < ativos.length; i++)
                    SizedBox(
                      width: largura,
                      height: largura * 1.7,
                      child: StatusCard(
                        story: ativos[i],
                        visto: stories.foiVisto(ativos[i]),
                        onTap: () => StoryViewerScreen.abrir(
                            context, ativos, i,
                            onVisto: stories.marcarVisto),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
