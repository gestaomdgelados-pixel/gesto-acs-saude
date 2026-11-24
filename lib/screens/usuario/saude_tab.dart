import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';
import '../../widgets/common/section_header.dart';

class SaudeTab extends StatelessWidget {
  const SaudeTab({super.key});

  @override
  Widget build(BuildContext context) {
    const seta = Icon(Icons.chevron_right_rounded);
    return RefreshableList(
      onRefresh: () async {},
      children: [
        const SectionHeader(
            titulo: 'Minha saúde', icone: Icons.favorite_rounded),
        ResumoTile(
          icone: Icons.vaccines_rounded,
          titulo: 'Carteira de vacinação',
          subtitulo: 'Concluídas, agendadas, atrasadas e pendentes da família',
          trailing: seta,
          onTap: () => context.push('/usuario/carteira'),
        ),
        ResumoTile(
          icone: Icons.home_work_rounded,
          titulo: 'Minhas visitas',
          subtitulo: 'Próximas, realizadas e canceladas',
          trailing: seta,
          onTap: () => context.push('/usuario/visitas'),
        ),
        ResumoTile(
          icone: Icons.support_agent_rounded,
          titulo: 'Contato do agente',
          subtitulo: 'Telefone, WhatsApp, dias e horários',
          trailing: seta,
          onTap: () => context.push('/usuario/agente'),
        ),
      ],
    );
  }
}
