import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/app_info_provider.dart';
import '../providers/session_provider.dart';
import '../providers/tema_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/atualizacao_aviso.dart';
import '../widgets/common/tema_action.dart';
import 'agente/familias_tab.dart';
import 'agente/painel_tab.dart';
import 'agente/perfil_tab.dart';
import 'agente/vacinas_tab.dart';
import 'agente/visitas_tab.dart';
import 'consultas_tab.dart';
import 'status_tab.dart';

class AgenteHomeScreen extends StatefulWidget {
  const AgenteHomeScreen({super.key});

  @override
  State<AgenteHomeScreen> createState() => _AgenteHomeScreenState();
}

class _AgenteHomeScreenState extends State<AgenteHomeScreen> {
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
                  onAbrir: () => context.push('/agente/configuracoes'),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _aba,
                children: const [
                  PainelTab(),
                  StatusTab(),
                  ConsultasTab(modo: ModoConsultas.agente),
                  FamiliasTab(),
                  VacinasTab(),
                  VisitasTab(),
                  PerfilTab(),
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
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign_rounded),
              label: 'Avisos'),
          NavigationDestination(
              icon: Icon(Icons.amp_stories_outlined),
              selectedIcon: Icon(Icons.amp_stories_rounded),
              label: 'Status'),
          NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services_rounded),
              label: 'Consultas'),
          NavigationDestination(
              icon: Icon(Icons.family_restroom_outlined),
              selectedIcon: Icon(Icons.family_restroom_rounded),
              label: 'Famílias'),
          NavigationDestination(
              icon: Icon(Icons.vaccines_outlined),
              selectedIcon: Icon(Icons.vaccines_rounded),
              label: 'Vacinas'),
          NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              selectedIcon: Icon(Icons.home_work_rounded),
              label: 'Visitas'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
