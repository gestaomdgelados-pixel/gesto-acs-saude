import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/membro.dart';
import '../../providers/agente_contato_provider.dart';
import '../../widgets/common/texto_dialog.dart';
import '../../providers/familias_provider.dart';
import '../../providers/vacinas_provider.dart';
import '../../widgets/agente/familia_resumo_card.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';
import '../../widgets/common/section_header.dart';

class FamiliaDetalheScreen extends StatelessWidget {
  const FamiliaDetalheScreen({super.key, required this.familiaId});

  final String familiaId;

  Future<void> _excluir(BuildContext context, Membro m) async {
    final fam = context.read<FamiliasProvider>();
    final vac = context.read<VacinasProvider>();
    final ok = await confirmar(context, 'Excluir pessoa',
        'Excluir ${m.nome}? Os registros de vacina dela também serão apagados.');
    if (!ok || !context.mounted) return;
    final erro = await fam.excluirMembro(m);
    if (!context.mounted) return;
    if (erro != null) {
      mostrarMensagem(context, erro, erro: true);
      return;
    }
    await vac.carregar();
  }

  Future<void> _vincular(BuildContext context) async {
    final prov = context.read<AgenteContatoProvider>();
    final usuario = await showDialog<String>(
      context: context,
      builder: (_) => const TextoDialog(
        titulo: 'Vincular login do morador',
        rotulo: 'Usuário do morador',
        ajuda: 'Digite o nome de usuário exato do login do morador. '
            'Ele passará a ver a carteira de vacinação e as visitas desta família.',
        botao: 'Vincular',
      ),
    );
    if (usuario == null || !context.mounted) return;
    final (nome, erro) = await prov.vincular(familiaId, usuario);
    if (!context.mounted) return;
    mostrarMensagem(context, erro ?? 'Família vinculada ao login de $nome.',
        erro: erro != null);
  }

  String _detalhe(Membro m) {
    final idade = m.idade;
    return [
      if (m.parentesco != null) m.parentesco!,
      if (idade != null) '$idade anos',
      if (m.gestante) 'Gestante',
      if (m.doencas.isNotEmpty) m.doencas.join(', '),
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final fam = context.watch<FamiliasProvider>();
    final f = fam.familiaPorId(familiaId);
    if (f == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Text(fam.carregando ? 'Carregando…' : 'Família não encontrada.')),
      );
    }
    final membros = fam.membrosDe(f.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(f.responsavel),
        actions: [
          IconButton(
            tooltip: 'Vincular login do morador',
            icon: const Icon(Icons.link_rounded),
            onPressed: () => _vincular(context),
          ),
          IconButton(
            tooltip: 'Editar família',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/agente/familia/${f.id}/editar'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: fam.carregar,
          children: [
            FamiliaResumoCard(familia: f),
            SectionHeader(
                titulo: 'Pessoas da família (${membros.length})',
                icone: Icons.groups_rounded),
            AsyncSection(
              carregando: fam.carregando,
              erro: fam.erro,
              vazio: membros.isEmpty,
              textoVazio: 'Nenhuma pessoa cadastrada. Toque em "Adicionar pessoa".',
              onTentarNovamente: fam.carregar,
              child: Column(
                children: [
                  for (final m in membros)
                    ResumoTile(
                      icone: Icons.person_rounded,
                      titulo: m.nome,
                      subtitulo: _detalhe(m),
                      onTap: () =>
                          context.push('/agente/familia/${f.id}/membro/${m.id}'),
                      trailing: IconButton(
                        tooltip: 'Excluir pessoa',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _excluir(context, m),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agente/familia/${f.id}/membro/novo'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Adicionar pessoa'),
      ),
    );
  }
}
