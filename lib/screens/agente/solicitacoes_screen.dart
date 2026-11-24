import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/solicitacoes_provider.dart';
import '../../widgets/agente/nova_solicitacao_sheet.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/solicitacao_card.dart';
import '../../theme/theme.dart';

class SolicitacoesScreen extends StatelessWidget {
  const SolicitacoesScreen({super.key});

  Future<void> _nova(BuildContext context) async {
    final provider = context.read<SolicitacoesProvider>();
    final enviada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NovaSolicitacaoSheet(onEnviar: provider.criar),
    );
    if (enviada == true && context.mounted) {
      mostrarMensagem(context, 'Solicitação enviada para a gestão.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final solic = context.watch<SolicitacoesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações à gestão')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: solic.carregar,
          children: [
            const SectionHeader(
                titulo: 'Minhas solicitações', icone: Icons.assignment_rounded),
            AsyncSection(
              carregando: solic.carregando,
              erro: solic.erro,
              vazio: solic.itens.isEmpty,
              textoVazio:
                  'Você ainda não enviou solicitações. Toque em "Nova solicitação".',
              onTentarNovamente: solic.carregar,
              child: Column(
                children: [
                  for (final s in solic.itens)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                      child: SolicitacaoCard(solicitacao: s),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nova(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova solicitação'),
      ),
    );
  }
}
