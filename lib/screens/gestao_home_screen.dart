import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/aviso.dart';
import '../models/solicitacao.dart';
import '../providers/app_info_provider.dart';
import '../providers/avisos_provider.dart';
import '../providers/documentos_provider.dart';
import '../providers/session_provider.dart';
import '../providers/solicitacoes_provider.dart';
import '../providers/stories_provider.dart';
import '../providers/tema_provider.dart';
import '../theme/theme.dart';
import '../widgets/admin/propaganda_form_sheet.dart';
import '../widgets/common/async_section.dart';
import '../widgets/common/atualizacao_aviso.dart';
import '../widgets/common/aviso_lista.dart';
import '../widgets/common/feedback.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/tema_action.dart';
import '../widgets/gestao/aviso_form_sheet.dart';
import '../widgets/gestao/decisao_sheet.dart';
import '../widgets/gestao/solicitacoes_gestao_list.dart';
import 'consultas_tab.dart';
import 'documentos_tab.dart';
import 'status_tab.dart';

class GestaoHomeScreen extends StatefulWidget {
  const GestaoHomeScreen({super.key});

  @override
  State<GestaoHomeScreen> createState() => _GestaoHomeScreenState();
}

class _GestaoHomeScreenState extends State<GestaoHomeScreen> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AppInfoProvider>().carregar();
    });
  }

  Future<void> _decidir(Solicitacao s, bool aceitar) async {
    final provider = context.read<SolicitacoesProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DecisaoSheet(
        solicitacao: s,
        aceitarInicial: aceitar,
        onAceitar: (quando) => provider.aceitar(s, quando),
        onRecusar: (motivo) => provider.recusar(s, motivo),
      ),
    );
    if (ok == true && mounted) mostrarMensagem(context, 'Solicitação atualizada.');
  }

  Future<void> _novoAviso() async {
    final avisos = context.read<AvisosProvider>();
    final stories = context.read<StoriesProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AvisoFormSheet(
        onSalvar: (AvisoRascunho r) => r.tipo == 'campanha'
            ? stories.publicarCampanha(r)
            : avisos.criar(r),
      ),
    );
    if (ok == true && mounted) mostrarMensagem(context, 'Publicado com sucesso.');
  }

  Future<void> _novoStatus() async {
    final stories = context.read<StoriesProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PropagandaFormSheet(
        onPublicar: stories.publicarMidia,
        titulo: 'Novo status (imagem ou vídeo)',
        botao: 'Publicar status',
      ),
    );
    if (ok == true && mounted) mostrarMensagem(context, 'Status publicado para todos.');
  }

  Future<void> _excluirAviso(Aviso a) async {
    final provider = context.read<AvisosProvider>();
    if (!await confirmar(context, 'Excluir aviso',
        'Excluir "${a.titulo}"? Os agentes deixarão de ver.')) {
      return;
    }
    final erro = await provider.excluir(a);
    if (mounted) mostrarMensagem(context, erro ?? 'Aviso excluído.', erro: erro != null);
  }

  @override
  Widget build(BuildContext context) {
    final solic = context.watch<SolicitacoesProvider>();
    final avisos = context.watch<AvisosProvider>();
    final docs = context.watch<DocumentosProvider>();
    final info = context.watch<AppInfoProvider>();

    final paginas = [
      SolicitacoesGestaoList(
        itens: solic.itens,
        carregando: solic.carregando,
        erro: solic.erro,
        onAtualizar: solic.carregar,
        onAceitar: (s) => _decidir(s, true),
        onRecusar: (s) => _decidir(s, false),
      ),
      RefreshableList(
        onRefresh: avisos.carregar,
        children: [
          const SectionHeader(
              titulo: 'Reuniões e avisos aos agentes',
              icone: Icons.event_note_rounded),
          AsyncSection(
            carregando: avisos.carregando,
            erro: avisos.erro,
            vazio: avisos.itens.isEmpty,
            textoVazio: 'Nada publicado ainda. Toque em "Publicar".',
            onTentarNovamente: avisos.carregar,
            child: AvisoLista(avisos: avisos.itens, onExcluir: _excluirAviso),
          ),
        ],
      ),
      const StatusTab(),
      const ConsultasTab(modo: ModoConsultas.gestao),
      const DocumentosTab(recebidos: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão ACS Saúde'),
        actions: [
          TemaAction(
            onAlternar: () => context
                .read<TemaProvider>()
                .alternar(Theme.of(context).brightness),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/gestao/configuracoes'),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<SessionProvider>().sair(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (info.temNova)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd,
                    AppTheme.spacingSm, AppTheme.spacingMd, 0),
                child: AtualizacaoAviso(
                  versao: info.ultima!.versao,
                  onAbrir: () => context.push('/gestao/configuracoes'),
                ),
              ),
            Expanded(child: IndexedStack(index: _aba, children: paginas)),
          ],
        ),
      ),
      floatingActionButton: switch (_aba) {
        1 => FloatingActionButton.extended(
            onPressed: _novoAviso,
            icon: const Icon(Icons.campaign_rounded),
            label: const Text('Publicar'),
          ),
        2 => FloatingActionButton.extended(
            onPressed: _novoStatus,
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('Novo status'),
          ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: solic.pendentes > 0,
              label: Text('${solic.pendentes}'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: const Icon(Icons.inbox_rounded),
            label: 'Pedidos',
          ),
          const NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign_rounded),
              label: 'Avisos'),
          const NavigationDestination(
              icon: Icon(Icons.amp_stories_outlined),
              selectedIcon: Icon(Icons.amp_stories_rounded),
              label: 'Status'),
          const NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services_rounded),
              label: 'Consultas'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: docs.novos > 0,
              label: Text('${docs.novos}'),
              child: const Icon(Icons.description_outlined),
            ),
            selectedIcon: const Icon(Icons.description_rounded),
            label: 'Docs',
          ),
        ],
      ),
    );
  }
}
