import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/visita.dart';
import '../../providers/familias_provider.dart';
import '../../providers/visitas_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/agente/justificar_visita_sheet.dart';
import '../../widgets/agente/nova_visita_sheet.dart';
import '../../widgets/agente/visita_tile.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';

class VisitasTab extends StatefulWidget {
  const VisitasTab({super.key});

  @override
  State<VisitasTab> createState() => _VisitasTabState();
}

class _VisitasTabState extends State<VisitasTab> {
  StatusVisita _filtro = StatusVisita.agendada;

  Future<void> _agendar() async {
    final vis = context.read<VisitasProvider>();
    final familias = context.read<FamiliasProvider>().familias;
    if (familias.isEmpty) {
      mostrarMensagem(context, 'Cadastre uma família antes de agendar visitas.',
          erro: true);
      return;
    }
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NovaVisitaSheet(familias: familias, onAgendar: vis.agendar),
    );
    if (ok == true && mounted) mostrarMensagem(context, 'Visita agendada.');
  }

  Future<void> _justificar(Visita v) async {
    final vis = context.read<VisitasProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          JustificarVisitaSheet(onSalvar: (texto) => vis.justificar(v.id, texto)),
    );
    if (ok == true && mounted) {
      mostrarMensagem(context, 'Justificativa registrada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vis = context.watch<VisitasProvider>();
    final fam = context.watch<FamiliasProvider>();
    final lista = vis.porStatus(_filtro);

    return Scaffold(
      body: RefreshableList(
        onRefresh: vis.carregar,
        children: [
          SegmentedButton<StatusVisita>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: StatusVisita.agendada, label: Text('A fazer')),
              ButtonSegment(value: StatusVisita.concluida, label: Text('Concluídas')),
              ButtonSegment(
                  value: StatusVisita.naoRealizada, label: Text('Não feitas')),
            ],
            selected: {_filtro},
            onSelectionChanged: (s) => setState(() => _filtro = s.first),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          OutlinedButton.icon(
            onPressed: () => context.push('/agente/relatorio'),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Relatório mensal (PDF)'),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AsyncSection(
            carregando: vis.carregando,
            erro: vis.erro,
            vazio: lista.isEmpty,
            textoVazio: switch (_filtro) {
              StatusVisita.agendada =>
                'Nenhuma visita a fazer. Toque em "Agendar visita".',
              StatusVisita.concluida => 'Nenhuma visita concluída ainda.',
              StatusVisita.naoRealizada => 'Nenhuma visita justificada.',
            },
            onTentarNovamente: vis.carregar,
            child: Column(
              children: [
                for (final v in lista)
                  VisitaTile(
                    visita: v,
                    familia: fam.nomeDaFamilia(v.familiaId),
                    onConcluir: () => context.push('/agente/visita/${v.id}/concluir'),
                    onJustificar: () => _justificar(v),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agendar,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agendar visita'),
      ),
    );
  }
}
