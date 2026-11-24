import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vacina.dart';
import '../../providers/vacinas_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/agente/tipo_vacina_sheet.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';

class VacinasConfigScreen extends StatelessWidget {
  const VacinasConfigScreen({super.key});

  Future<void> _nova(BuildContext context) async {
    final vac = context.read<VacinasProvider>();
    final criada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TipoVacinaSheet(onSalvar: vac.criarTipo),
    );
    if (criada == true && context.mounted) {
      mostrarMensagem(context, 'Vacina cadastrada para todas as pessoas.');
    }
  }

  Future<void> _excluir(BuildContext context, VacinaTipo t) async {
    final vac = context.read<VacinasProvider>();
    final ok = await confirmar(context, 'Excluir vacina',
        'Excluir "${t.nome}"? Os agendamentos e registros dela, de todas as pessoas, também serão apagados.');
    if (!ok || !context.mounted) return;
    final erro = await vac.excluirTipo(t);
    if (erro != null && context.mounted) {
      mostrarMensagem(context, erro, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vac = context.watch<VacinasProvider>();
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de vacinas')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: vac.carregar,
          children: [
            Text(
              'As vacinas cadastradas aqui valem para todas as pessoas das famílias, as já cadastradas e as novas.',
              style: text.bodyMedium?.copyWith(color: app.subtleText),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            AsyncSection(
              carregando: vac.carregando,
              erro: vac.erro,
              vazio: vac.tipos.isEmpty,
              textoVazio: 'Nenhuma vacina cadastrada. Toque em "Nova vacina".',
              onTentarNovamente: vac.carregar,
              child: Column(
                children: [
                  for (final t in vac.tipos)
                    ResumoTile(
                      icone: Icons.vaccines_rounded,
                      titulo: t.nome,
                      subtitulo: t.descricao,
                      trailing: IconButton(
                        tooltip: 'Excluir vacina',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _excluir(context, t),
                      ),
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
        label: const Text('Nova vacina'),
      ),
    );
  }
}
