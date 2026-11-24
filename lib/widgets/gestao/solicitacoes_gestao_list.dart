import 'package:flutter/material.dart';

import '../../models/solicitacao.dart';
import '../../theme/theme.dart';
import '../common/async_section.dart';
import '../common/refreshable_list.dart';
import '../common/section_header.dart';
import '../common/solicitacao_card.dart';

class SolicitacoesGestaoList extends StatefulWidget {
  const SolicitacoesGestaoList({
    super.key,
    required this.itens,
    required this.carregando,
    required this.erro,
    required this.onAtualizar,
    required this.onAceitar,
    required this.onRecusar,
  });

  final List<Solicitacao> itens;
  final bool carregando;
  final String? erro;
  final Future<void> Function() onAtualizar;
  final ValueChanged<Solicitacao> onAceitar;
  final ValueChanged<Solicitacao> onRecusar;

  @override
  State<SolicitacoesGestaoList> createState() => _SolicitacoesGestaoListState();
}

class _SolicitacoesGestaoListState extends State<SolicitacoesGestaoList> {
  bool _somentePendentes = true;

  @override
  Widget build(BuildContext context) {
    final lista = _somentePendentes
        ? widget.itens
            .where((s) => s.status == StatusSolicitacao.pendente)
            .toList()
        : widget.itens;

    return RefreshableList(
      onRefresh: widget.onAtualizar,
      children: [
        const SectionHeader(
            titulo: 'Solicitações recebidas', icone: Icons.inbox_rounded),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Pendentes')),
            ButtonSegment(value: false, label: Text('Todas')),
          ],
          selected: {_somentePendentes},
          onSelectionChanged: (s) =>
              setState(() => _somentePendentes = s.first),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AsyncSection(
          carregando: widget.carregando,
          erro: widget.erro,
          vazio: lista.isEmpty,
          textoVazio: _somentePendentes
              ? 'Nenhuma solicitação pendente.'
              : 'Nenhuma solicitação recebida ainda.',
          onTentarNovamente: widget.onAtualizar,
          child: Column(
            children: [
              for (final s in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: SolicitacaoCard(
                    solicitacao: s,
                    acoes: s.status != StatusSolicitacao.pendente
                        ? null
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => widget.onRecusar(s),
                                  child: const Text('Recusar'),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => widget.onAceitar(s),
                                  child: const Text('Aceitar'),
                                ),
                              ),
                            ],
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
