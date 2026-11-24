import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/app_info_provider.dart';
import '../providers/tema_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/atualizacao_aviso.dart';
import '../widgets/common/tema_action.dart';

import '../models/profile.dart';
import '../models/story.dart';
import '../providers/admin_provider.dart';
import '../providers/session_provider.dart';
import '../providers/stories_provider.dart';
import '../widgets/admin/admin_logins_tab.dart';
import '../widgets/admin/admin_logs_tab.dart';
import '../widgets/admin/admin_propagandas_tab.dart';
import '../widgets/admin/propaganda_form_sheet.dart';
import '../widgets/admin/senha_dialog.dart';
import '../widgets/admin/usuario_form_sheet.dart';
import '../widgets/common/feedback.dart';
import 'story_viewer_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AppInfoProvider>().carregar();
    });
  }

  void _avisar(String? erro, String sucesso) {
    if (mounted) mostrarMensagem(context, erro ?? sucesso, erro: erro != null);
  }

  Future<void> _formLogin([Profile? existente]) async {
    final admin = context.read<AdminProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => UsuarioFormSheet(
        existente: existente,
        agentes: admin.agentes,
        onSalvar: (d) =>
            existente == null ? admin.criar(d) : admin.editar(existente, d),
      ),
    );
    if (ok == true) {
      _avisar(null, existente == null ? 'Login criado e já ativo.' : 'Login atualizado.');
    }
  }

  Future<void> _senha(Profile p) async {
    final admin = context.read<AdminProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => SenhaDialog(
          nome: p.nome, onSalvar: (senha) => admin.trocarSenha(p, senha)),
    );
    if (ok == true) _avisar(null, 'Senha alterada. A pessoa deverá trocá-la no próximo acesso.');
  }

  Future<void> _excluirLogin(Profile p) async {
    final admin = context.read<AdminProvider>();
    if (!await confirmar(context, 'Excluir login',
        'Excluir "${p.nome}" (@${p.usuario})? Essa ação não pode ser desfeita.')) {
      return;
    }
    _avisar(await admin.excluir(p), 'Login excluído.');
  }

  Future<void> _novaPropaganda() async {
    final stories = context.read<StoriesProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PropagandaFormSheet(onPublicar: stories.publicarMidia),
    );
    if (ok == true) _avisar(null, 'Propaganda publicada para todos os logins.');
  }

  Future<void> _excluirPropaganda(Story s) async {
    final stories = context.read<StoriesProvider>();
    if (!await confirmar(context, 'Excluir propaganda', 'Excluir "${s.titulo}"?')) {
      return;
    }
    _avisar(await stories.excluir(s), 'Propaganda excluída.');
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final admin = context.watch<AdminProvider>();
    final stories = context.watch<StoriesProvider>();
    final info = context.watch<AppInfoProvider>();

    final paginas = [
      AdminLoginsTab(
        usuarios: admin.usuarios,
        carregando: admin.carregando,
        erro: admin.erro,
        idAtual: session.perfil?.id,
        onAtualizar: admin.carregar,
        onEditar: _formLogin,
        onSenha: _senha,
        onExcluir: _excluirLogin,
      ),
      AdminPropagandasTab(
        stories: stories.itens,
        carregando: stories.carregando,
        erro: stories.erro,
        onAtualizar: stories.carregar,
        onAbrir: (s) => StoryViewerScreen.abrir(context, [s], 0),
        onAlterarAtivo: (s, v) async =>
            _avisar(await stories.alterarAtivo(s, v), v ? 'Propaganda ativada.' : 'Propaganda pausada.'),
        onExcluir: _excluirPropaganda,
      ),
      AdminLogsTab(
        logs: admin.logs,
        carregando: admin.carregando,
        erro: admin.erroLogs,
        nomeDe: admin.nomeDe,
        onAtualizar: admin.carregar,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão ACS Saúde · Admin'),
        actions: [
          TemaAction(
            onAlternar: () => context
                .read<TemaProvider>()
                .alternar(Theme.of(context).brightness),
          ),
          IconButton(
            tooltip: 'Mudar minha senha',
            icon: const Icon(Icons.key_rounded),
            onPressed: () => context.push('/trocar-senha'),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/admin/configuracoes'),
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
                  onAbrir: () => context.push('/admin/configuracoes'),
                ),
              ),
            Expanded(child: IndexedStack(index: _aba, children: paginas)),
          ],
        ),
      ),
      floatingActionButton: switch (_aba) {
        0 => FloatingActionButton.extended(
            onPressed: () => _formLogin(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Novo login'),
          ),
        1 => FloatingActionButton.extended(
            onPressed: _novaPropaganda,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('Nova propaganda'),
          ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Logins'),
          NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign_rounded),
              label: 'Propagandas'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_toggle_off_rounded),
              label: 'Registros'),
        ],
      ),
    );
  }
}
