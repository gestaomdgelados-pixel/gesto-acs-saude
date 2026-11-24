import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/consulta.dart';
import '../providers/admin_provider.dart';
import '../providers/agente_contato_provider.dart';
import '../providers/morador_provider.dart';
import '../repositories/contato_agente_repository.dart';
import '../repositories/morador_repository.dart';
import '../screens/usuario/carteira_screen.dart';
import '../screens/usuario/contato_agente_screen.dart';
import '../screens/usuario/visitas_morador_screen.dart';
import '../providers/avisos_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/consultas_provider.dart';
import '../providers/documentos_provider.dart';
import '../providers/familias_provider.dart';
import '../providers/permissoes_provider.dart';
import '../providers/session_provider.dart';
import '../providers/solicitacoes_provider.dart';
import '../providers/stories_provider.dart';
import '../providers/vacinas_provider.dart';
import '../providers/visitas_provider.dart';
import '../repositories/admin_repository.dart';
import '../repositories/arquivo_repository.dart';
import '../repositories/aviso_repository.dart';
import '../repositories/backup_repository.dart';
import '../repositories/consulta_repository.dart';
import '../repositories/documento_repository.dart';
import '../repositories/familia_repository.dart';
import '../repositories/permissoes_repository.dart';
import '../repositories/solicitacao_repository.dart';
import '../repositories/story_repository.dart';
import '../repositories/vacina_repository.dart';
import '../repositories/visita_repository.dart';
import '../screens/admin_home_screen.dart';
import '../screens/agente/documentos_screen.dart';
import '../screens/agente/familia_detalhe_screen.dart';
import '../screens/agente/familia_form_screen.dart';
import '../screens/agente/membro_form_screen.dart';
import '../screens/agente/relatorio_screen.dart';
import '../screens/agente/solicitacoes_screen.dart';
import '../screens/agente/vacinas_config_screen.dart';
import '../screens/agente/visita_concluir_screen.dart';
import '../screens/agente_home_screen.dart';
import '../screens/configuracoes_screen.dart';
import '../screens/gestao_home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/trocar_senha_screen.dart';
import '../screens/usuario_home_screen.dart';
import '../services/backup_cripto.dart';
import '../services/relatorio_visitas_service.dart';

class AppRouter {
  AppRouter._();

  static const _abertas = {'/', '/login'};

  static String? _redirect(SessionProvider s, String local) {
    if (s.status == SessaoStatus.carregando) return local == '/' ? null : '/';
    if (s.status == SessaoStatus.deslogado) {
      return local == '/login' ? null : '/login';
    }
    // Só o admin pode mudar a própria senha, e é opcional.
    if (local == '/trocar-senha') {
      return s.rotaInicial == '/admin' ? null : s.rotaInicial;
    }
    // Cada perfil só acessa a própria área.
    if (_abertas.contains(local) || !local.startsWith(s.rotaInicial)) {
      return s.rotaInicial;
    }
    return null;
  }

  static GoRouter create(SessionProvider session) {
    final client = Supabase.instance.client;
    StoriesProvider stories({bool todos = false}) =>
        StoriesProvider(StoryRepository(client), incluirInativos: todos)
          ..carregar();
    ConsultasProvider consultas(ModoConsultas modo) =>
        ConsultasProvider(ConsultaRepository(client), modo)..carregar();
    DocumentosProvider documentos({required bool recebidos}) =>
        DocumentosProvider(DocumentoRepository(client), ArquivoRepository(),
            recebidos: recebidos)
          ..carregar();
    MoradorProvider morador() =>
        MoradorProvider(MoradorRepository(client))..carregar();
    GoRoute configuracoes() => GoRoute(
          path: 'configuracoes',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => BackupProvider(BackupRepository(client),
                    BackupCripto(), ArquivoRepository()),
              ),
              ChangeNotifierProvider(
                create: (_) => PermissoesProvider(
                    PermissoesRepository(client), ArquivoRepository())
                  ..verificar(),
              ),
            ],
            child: const ConfiguracoesScreen(),
          ),
        );

    return GoRouter(
      initialLocation: '/',
      refreshListenable: session,
      redirect: (context, state) => _redirect(session, state.matchedLocation),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: '/trocar-senha',
            builder: (context, state) => const TrocarSenhaScreen()),
        GoRoute(
          path: '/usuario',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => stories()),
              ChangeNotifierProvider(
                  create: (_) => consultas(ModoConsultas.usuario)),
            ],
            child: const UsuarioHomeScreen(),
          ),
          routes: [
            configuracoes(),
            GoRoute(
              path: 'carteira',
              builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => morador(), child: const CarteiraScreen()),
            ),
            GoRoute(
              path: 'visitas',
              builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => morador(),
                  child: const VisitasMoradorScreen()),
            ),
            GoRoute(
              path: 'agente',
              builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => morador(), child: const ContatoAgenteScreen()),
            ),
          ],
        ),
        // Os providers ficam no ShellRoute para valer também nas telas
        // internas do agente (família, pessoa, visita, relatório...).
        ShellRoute(
          builder: (context, state, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => stories()),
              ChangeNotifierProvider(
                  create: (_) =>
                      AvisosProvider(AvisoRepository(client))..carregar()),
              ChangeNotifierProvider(
                create: (_) => SolicitacoesProvider(
                    SolicitacaoRepository(client),
                    agenteId: session.perfil?.id)
                  ..carregar(),
              ),
              ChangeNotifierProvider(
                  create: (_) =>
                      FamiliasProvider(FamiliaRepository(client))..carregar()),
              ChangeNotifierProvider(
                  create: (_) =>
                      VacinasProvider(VacinaRepository(client))..carregar()),
              ChangeNotifierProvider(
                create: (_) => VisitasProvider(
                    VisitaRepository(client), RelatorioVisitasService())
                  ..carregar(),
              ),
              ChangeNotifierProvider(
                  create: (_) => consultas(ModoConsultas.agente)),
              ChangeNotifierProvider(
                  create: (_) => documentos(recebidos: false)),
              ChangeNotifierProvider(
                  create: (_) =>
                      AgenteContatoProvider(ContatoAgenteRepository(client))
                        ..carregar()),
            ],
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/agente',
              builder: (context, state) => const AgenteHomeScreen(),
              routes: [
                GoRoute(
                  path: 'nova-familia',
                  builder: (context, state) => const FamiliaFormScreen(),
                ),
                GoRoute(
                  path: 'familia/:id',
                  builder: (context, state) => FamiliaDetalheScreen(
                      familiaId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'familia/:id/editar',
                  builder: (context, state) =>
                      FamiliaFormScreen(familiaId: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'familia/:id/membro/novo',
                  builder: (context, state) => MembroFormScreen(
                      familiaId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'familia/:id/membro/:mid',
                  builder: (context, state) => MembroFormScreen(
                    familiaId: state.pathParameters['id']!,
                    membroId: state.pathParameters['mid'],
                  ),
                ),
                GoRoute(
                  path: 'vacinas-config',
                  builder: (context, state) => const VacinasConfigScreen(),
                ),
                GoRoute(
                  path: 'solicitacoes',
                  builder: (context, state) => const SolicitacoesScreen(),
                ),
                GoRoute(
                  path: 'documentos',
                  builder: (context, state) => const DocumentosScreen(),
                ),
                GoRoute(
                  path: 'visita/:id/concluir',
                  builder: (context, state) => VisitaConcluirScreen(
                      visitaId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'relatorio',
                  builder: (context, state) => const RelatorioScreen(),
                ),
                configuracoes(),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/gestao',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => stories()),
              ChangeNotifierProvider(
                  create: (_) =>
                      AvisosProvider(AvisoRepository(client))..carregar()),
              ChangeNotifierProvider(
                  create: (_) =>
                      SolicitacoesProvider(SolicitacaoRepository(client))
                        ..carregar()),
              ChangeNotifierProvider(
                  create: (_) => consultas(ModoConsultas.gestao)),
              ChangeNotifierProvider(
                  create: (_) => documentos(recebidos: true)),
            ],
            child: const GestaoHomeScreen(),
          ),
          routes: [configuracoes()],
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => stories(todos: true)),
              ChangeNotifierProvider(
                  create: (_) =>
                      AdminProvider(AdminRepository(client))..carregar()),
            ],
            child: const AdminHomeScreen(),
          ),
          routes: [configuracoes()],
        ),
      ],
    );
  }
}
