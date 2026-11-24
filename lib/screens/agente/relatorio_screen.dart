import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/visita.dart';
import '../../providers/familias_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/visitas_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/agente/estatisticas_grid.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/formatos.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/status_chip.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  late final List<DateTime> _meses = VisitasProvider.mesesFechados(DateTime.now());
  late DateTime _mes = _meses.first;
  bool _gerando = false;
  String? _erro;

  Future<void> _gerar() async {
    final vis = context.read<VisitasProvider>();
    final familias = context.read<FamiliasProvider>().familias;
    final agente = context.read<SessionProvider>().perfil?.nome ?? 'Agente';
    setState(() {
      _gerando = true;
      _erro = null;
    });
    final erro =
        await vis.exportarRelatorio(_mes, familias: familias, agente: agente);
    if (!mounted) return;
    setState(() {
      _gerando = false;
      _erro = erro;
    });
    if (erro == null) mostrarMensagem(context, 'Relatório gerado.');
  }

  @override
  Widget build(BuildContext context) {
    final vis = context.watch<VisitasProvider>();
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final doMes = vis.doMes(_mes);
    int conta(StatusVisita s) => doMes.where((v) => v.status == s).length;
    final aviso = vis.erro;
    final erroPdf = _erro;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório mensal')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: vis.carregar,
          children: [
            Text(
              'Escolha um mês já encerrado. O PDF reúne todas as visitas do mês e as informações de cada uma.',
              style: text.bodyMedium?.copyWith(color: app.subtleText),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: [
                for (final m in _meses)
                  ChoiceChip(
                    label: Text(mesAno(m)),
                    selected: m == _mes,
                    onSelected: (_) => setState(() => _mes = m),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (aviso != null) ...[
              ErrorBanner(mensagem: aviso, onTentarNovamente: vis.carregar),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            EstatisticasGrid(itens: [
              EstatisticaItem(
                  icone: Icons.home_work_rounded,
                  valor: doMes.length,
                  rotulo: 'Visitas no mês'),
              EstatisticaItem(
                  icone: Icons.task_alt_rounded,
                  valor: conta(StatusVisita.concluida),
                  rotulo: 'Concluídas',
                  tom: StatusTom.sucesso),
              EstatisticaItem(
                  icone: Icons.edit_note_rounded,
                  valor: conta(StatusVisita.naoRealizada),
                  rotulo: 'Não realizadas'),
              EstatisticaItem(
                  icone: Icons.pending_actions_rounded,
                  valor: conta(StatusVisita.agendada),
                  rotulo: 'Pendentes',
                  tom: StatusTom.aviso),
            ]),
            if (doMes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: Text('Nenhuma visita em ${mesAno(_mes)}.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: app.subtleText)),
              ),
            if (erroPdf != null) ...[
              ErrorBanner(mensagem: erroPdf),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            FilledButton.icon(
              onPressed: doMes.isEmpty || _gerando ? null : _gerar,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(_gerando ? 'Gerando…' : 'Gerar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
