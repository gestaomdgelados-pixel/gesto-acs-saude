import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/alerta_atraso.dart';
import '../../models/resumo_agente.dart';
import '../../providers/avisos_provider.dart';
import '../../providers/familias_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/vacinas_provider.dart';
import '../../providers/visitas_provider.dart';
import '../../widgets/agente/alertas_quadro.dart';
import '../../widgets/agente/estatisticas_grid.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/avisos_destaque.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/formatos.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';
import '../../widgets/common/saudacao_header.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_chip.dart';

class PainelTab extends StatelessWidget {
  const PainelTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final avisos = context.watch<AvisosProvider>();
    final fam = context.watch<FamiliasProvider>();
    final vac = context.watch<VacinasProvider>();
    final vis = context.watch<VisitasProvider>();
    final agora = DateTime.now();

    final r = ResumoAgente.calcular(
      familias: fam.familias,
      membros: fam.membros,
      tipos: vac.tipos,
      registros: vac.registros,
      visitas: vis.itens,
      agora: agora,
    );
    final alertas = AlertaAtraso.calcular(
      familias: fam.familias,
      membros: fam.membros,
      tipos: vac.tipos,
      registros: vac.registros,
      visitas: vis.itens,
      agora: agora,
    );
    final proximasVisitas = vis.proximas(3);

    final itens = [
      EstatisticaItem(
          icone: Icons.family_restroom_rounded, valor: r.familias, rotulo: 'Famílias'),
      EstatisticaItem(
          icone: Icons.groups_rounded, valor: r.membros, rotulo: 'Pessoas cadastradas'),
      EstatisticaItem(
          icone: Icons.pregnant_woman_rounded, valor: r.gestantes, rotulo: 'Gestantes'),
      EstatisticaItem(
          icone: Icons.monitor_heart_rounded, valor: r.hipertensos, rotulo: 'Hipertensos'),
      EstatisticaItem(
          icone: Icons.bloodtype_rounded, valor: r.diabeticos, rotulo: 'Diabéticos'),
      EstatisticaItem(
          icone: Icons.vaccines_rounded,
          valor: r.vacinasPendentes,
          rotulo: 'Vacinas a fazer',
          tom: StatusTom.aviso),
      EstatisticaItem(
          icone: Icons.today_rounded, valor: r.visitasHoje, rotulo: 'Visitas hoje'),
      EstatisticaItem(
          icone: Icons.task_alt_rounded,
          valor: r.visitasConcluidasMes,
          rotulo: 'Concluídas no mês',
          tom: StatusTom.sucesso),
    ];

    Future<void> recarregar() => Future.wait([
          avisos.carregar(),
          fam.carregar(),
          vac.carregar(),
          vis.carregar(),
        ]);

    final erroDados = fam.erro ?? vac.erro ?? vis.erro;

    return RefreshableList(
      onRefresh: recarregar,
      children: [
        SaudacaoHeader(
            nome: session.perfil?.nome ?? '', perfil: 'Agente de saúde'),
        AvisosDestaque(
          avisos: avisos.itens,
          carregando: avisos.carregando,
          erro: avisos.erro,
          onTentarNovamente: avisos.carregar,
        ),
        if (erroDados != null)
          ErrorBanner(mensagem: erroDados, onTentarNovamente: recarregar)
        else
          AlertasQuadro(alertas: alertas),
        const SectionHeader(titulo: 'Resumo', icone: Icons.dashboard_rounded),
        EstatisticasGrid(itens: itens),
        const SectionHeader(
            titulo: 'Próximas visitas', icone: Icons.home_work_rounded),
        AsyncSection(
          carregando: vis.carregando,
          erro: vis.erro,
          vazio: proximasVisitas.isEmpty,
          textoVazio: 'Nenhuma visita agendada.',
          onTentarNovamente: vis.carregar,
          child: Column(
            children: [
              for (final v in proximasVisitas)
                ResumoTile(
                  icone: Icons.home_work_rounded,
                  titulo: fam.nomeDaFamilia(v.familiaId),
                  subtitulo: '${dataExtensa(v.agendadaPara)} · ${v.motivo}',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
