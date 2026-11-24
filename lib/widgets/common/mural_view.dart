import 'package:flutter/material.dart';

import '../../models/story.dart';
import '../../theme/theme.dart';
import 'async_section.dart';
import 'aviso_card.dart';
import 'formatos.dart';
import 'propaganda_carousel.dart';
import 'section_header.dart';

class MuralView extends StatelessWidget {
  const MuralView({
    super.key,
    required this.stories,
    required this.carregando,
    required this.erro,
    required this.onTentarNovamente,
    required this.onAbrir,
  });

  final List<Story> stories;
  final bool carregando;
  final String? erro;
  final VoidCallback onTentarNovamente;
  final ValueChanged<int> onAbrir;

  @override
  Widget build(BuildContext context) {
    final campanhas = stories.where((s) => s.isCampanhaTexto).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
            titulo: 'Propagandas', icone: Icons.campaign_rounded),
        AsyncSection(
          carregando: carregando,
          erro: erro,
          vazio: stories.isEmpty,
          textoVazio: 'Nenhuma propaganda no momento.',
          onTentarNovamente: onTentarNovamente,
          child: PropagandaCarousel(stories: stories, onAbrir: onAbrir),
        ),
        if (campanhas.isNotEmpty) ...[
          const SectionHeader(
              titulo: 'Avisos de campanha', icone: Icons.vaccines_rounded),
          for (final c in campanhas)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: AvisoCard(
                titulo: c.titulo,
                rotulo: 'Campanha',
                icone: Icons.vaccines_rounded,
                descricao: c.texto,
                data: c.criadoEm == null ? null : dataCurta(c.criadoEm!),
                onTap: () => onAbrir(stories.indexOf(c)),
              ),
            ),
        ],
      ],
    );
  }
}
