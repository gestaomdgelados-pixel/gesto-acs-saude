import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/visita.dart';
import '../../providers/morador_provider.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/motivo_dialog.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/usuario/visita_morador_tile.dart';
import 'carteira_screen.dart';

class VisitasMoradorScreen extends StatelessWidget {
  const VisitasMoradorScreen({super.key});

  Future<void> _cancelar(BuildContext context, Visita v) async {
    final prov = context.read<MoradorProvider>();
    final motivo = await showDialog<String>(
      context: context,
      builder: (_) =>
          const MotivoDialog(titulo: 'Cancelar visita — informe a justificativa'),
    );
    if (motivo == null || !context.mounted) return;
    final erro = await prov.cancelarVisita(v.id, motivo);
    if (!context.mounted) return;
    mostrarMensagem(context, erro ?? 'Visita cancelada. O agente foi avisado.',
        erro: erro != null);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MoradorProvider>();
    final agente = m.contato?.nome ?? '';
    Widget lista(List<Visita> vs, String vazio, {bool cancelar = false}) =>
        vs.isEmpty
            ? Text(vazio)
            : Column(
                children: [
                  for (final v in vs)
                    VisitaMoradorTile(
                      visita: v,
                      agente: agente,
                      onCancelar: cancelar ? () => _cancelar(context, v) : null,
                    ),
                ],
              );

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas visitas')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: m.carregar,
          children: [
            AsyncSection(
              carregando: m.carregando,
              erro: m.erro,
              vazio: m.visitas.isEmpty,
              textoVazio: m.vinculado
                  ? 'Nenhuma visita registrada ainda.'
                  : semVinculo,
              onTentarNovamente: m.carregar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                      titulo: 'Próximas visitas', icone: Icons.event_rounded),
                  lista(m.proximas, 'Nenhuma visita agendada.', cancelar: true),
                  const SectionHeader(
                      titulo: 'Visitas realizadas',
                      icone: Icons.check_circle_rounded),
                  lista(m.realizadas, 'Nenhuma visita realizada ainda.'),
                  const SectionHeader(
                      titulo: 'Canceladas ou não realizadas',
                      icone: Icons.event_busy_rounded),
                  lista(m.canceladas, 'Nenhuma visita cancelada.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
