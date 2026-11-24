import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/membro.dart';
import '../../models/vacina.dart';
import '../../providers/familias_provider.dart';
import '../../providers/vacinas_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/agente/concluir_vacina_sheet.dart';
import '../../widgets/agente/vacina_item_tile.dart';
import '../../widgets/agente/vacina_membro_card.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/section_header.dart';

class VacinasTab extends StatelessWidget {
  const VacinasTab({super.key});

  void _resultado(BuildContext context, String? erro, String ok) {
    if (!context.mounted) return;
    if (erro == null) {
      mostrarMensagem(context, ok);
    } else {
      mostrarMensagem(context, erro, erro: true);
    }
  }

  Future<void> _acao(
      BuildContext context, Membro m, VacinaItem item, AcaoVacina acao) async {
    final vac = context.read<VacinasProvider>();
    switch (acao) {
      case AcaoVacina.agendar:
        final hoje = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: hoje,
          firstDate: hoje,
          lastDate: hoje.add(const Duration(days: 730)),
        );
        if (d == null || !context.mounted) return;
        final erro = await vac.agendar(m.id, item.tipo.id, d);
        if (context.mounted) _resultado(context, erro, 'Vacina agendada.');
      case AcaoVacina.concluir:
        final feita = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => ConcluirVacinaSheet(
            titulo: '${item.tipo.nome} - ${m.nome}',
            onConfirmar: (data, quem, lote) =>
                vac.concluir(m.id, item.tipo.id, data, quem, lote),
          ),
        );
        if (feita == true && context.mounted) {
          mostrarMensagem(context, 'Vacina concluída.');
        }
      case AcaoVacina.excluir:
        final registro = item.registro;
        if (registro == null) return;
        final ok = await confirmar(
          context,
          item.concluida ? 'Excluir registro' : 'Excluir agendamento',
          '${item.tipo.nome} - ${m.nome}',
        );
        if (!ok || !context.mounted) return;
        final erro = await vac.excluirRegistro(registro.id);
        if (context.mounted) _resultado(context, erro, 'Registro excluído.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fam = context.watch<FamiliasProvider>();
    final vac = context.watch<VacinasProvider>();

    return RefreshableList(
      onRefresh: () => Future.wait([fam.carregar(), vac.carregar()]),
      children: [
        const SectionHeader(
            titulo: 'Vacinas das pessoas', icone: Icons.vaccines_rounded),
        OutlinedButton.icon(
          onPressed: () => context.push('/agente/vacinas-config'),
          icon: const Icon(Icons.settings_rounded),
          label: const Text('Cadastro de vacinas'),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AsyncSection(
          carregando: vac.carregando || fam.carregando,
          erro: vac.erro ?? fam.erro,
          vazio: fam.membros.isEmpty || vac.tipos.isEmpty,
          textoVazio: vac.tipos.isEmpty
              ? 'Nenhuma vacina cadastrada. Use "Cadastro de vacinas" acima.'
              : 'Cadastre pessoas nas famílias para acompanhar as vacinas.',
          onTentarNovamente: () => Future.wait([fam.carregar(), vac.carregar()]),
          child: Column(
            children: [
              for (final m in fam.membros)
                VacinaMembroCard(
                  membro: m,
                  itens: vac.itensDe(m.id),
                  nomeFamilia: fam.nomeDaFamilia(m.familiaId),
                  onAcao: (item, acao) => _acao(context, m, item, acao),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
