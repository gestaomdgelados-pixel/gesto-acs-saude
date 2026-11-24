import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/app_info_provider.dart';
import '../providers/session_provider.dart';
import '../providers/stories_provider.dart';
import '../providers/tema_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/atualizacao_aviso.dart';
import '../widgets/common/mural_view.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/saudacao_header.dart';
import '../widgets/common/tema_action.dart';
import 'consultas_tab.dart';
import 'status_tab.dart';
import 'story_viewer_screen.dart';
import 'usuario/saude_tab.dart';

class UsuarioHomeScreen extends StatefulWidget {
  const UsuarioHomeScreen({super.key});

  @override
  State<UsuarioHomeScreen> createState() => _UsuarioHomeScreenState();
}

class _UsuarioHomeScreenState extends State<UsuarioHomeScreen> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AppInfoProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final stories = context.watch<StoriesProvider>();
    final info = context.watch<AppInfoProvider>();

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
            onPressed: () => context.push('/usuario/configuracoes'),
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
                  onAbrir: () => context.push('/usuario/configuracoes'),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _aba,
                children: [
                  RefreshableList(
                    onRefresh: stories.carregar,
                    children: [
                      SaudacaoHeader(
                        nome: session.perfil?.nome ?? '',
                        perfil: 'Usuário comum',
                      ),
                      MuralView(
                        stories: stories.ativos,
                        carregando: stories.carregando,
                        erro: stories.erro,
                        onTentarNovamente: stories.carregar,
                        onAbrir: (i) => StoryViewerScreen.abrir(
                            context, stories.ativos, i,
                            onVisto: stories.marcarVisto),
                      ),
                    ],
                  ),
                  const StatusTab(),
                  const ConsultasTab(modo: ModoConsultas.usuario),
                  const SaudeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.amp_stories_outlined),
              selectedIcon: Icon(Icons.amp_stories_rounded),
              label: 'Status'),
          NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services_rounded),
              label: 'Consultas'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Saúde'),
        ],
      ),
    );
  }
}
