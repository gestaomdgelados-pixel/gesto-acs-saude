import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/app_info_provider.dart';
import 'providers/session_provider.dart';
import 'providers/tema_provider.dart';
import 'repositories/arquivo_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/config_repository.dart';
import 'repositories/prefs_repository.dart';
import 'router/app_router.dart';
import 'screens/startup_error_screen.dart';
import 'theme/theme.dart';
import 'widgets/common/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? erro;
  try {
    await initializeDateFormatting('pt_BR');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
    );
  } catch (e) {
    erro = 'Não foi possível conectar ao servidor: $e';
  }
  runApp(AcsApp(erroInicial: erro));
}

class AcsApp extends StatefulWidget {
  const AcsApp({super.key, this.erroInicial});
  final String? erroInicial;

  @override
  State<AcsApp> createState() => _AcsAppState();
}

class _AcsAppState extends State<AcsApp> {
  SessionProvider? _session;
  GoRouter? _router;
  AppInfoProvider? _info;
  final _tema = TemaProvider(PrefsRepository());

  @override
  void initState() {
    super.initState();
    _tema.carregar();
    if (widget.erroInicial == null) {
      final session = SessionProvider(
          AuthRepository(Supabase.instance.client), PrefsRepository())
        ..iniciar();
      _session = session;
      _router = AppRouter.create(session);
      _info = AppInfoProvider(
          ConfigRepository(Supabase.instance.client), ArquivoRepository());
    }
  }

  @override
  void dispose() {
    _router?.dispose();
    _session?.dispose();
    _info?.dispose();
    _tema.dispose();
    super.dispose();
  }

  static const _locais = [Locale('pt', 'BR')];
  static const _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final router = _router;
    final info = _info;
    if (session == null || router == null || info == null) {
      return MaterialApp(
        title: 'Gestão ACS Saúde',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: _locais.first,
        supportedLocales: _locais,
        localizationsDelegates: _delegates,
        home: StartupErrorScreen(mensagem: widget.erroInicial ?? ''),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: _tema),
        ChangeNotifierProvider.value(value: info),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, tema, _) => MaterialApp.router(
          title: 'Gestão ACS Saúde',
          theme: AppTheme.build(Brightness.light,
              cor: tema.cor,
              fonte: tema.fonte,
              degrade: tema.degrade,
              opacidadeBalao: tema.transparenciaBalao),
          darkTheme: AppTheme.build(Brightness.dark,
              cor: tema.cor,
              fonte: tema.fonte,
              degrade: tema.degrade,
              opacidadeBalao: tema.transparenciaBalao),
          themeMode: tema.modo,
          locale: _locais.first,
          supportedLocales: _locais,
          localizationsDelegates: _delegates,
          // Fundo dia/noite atrás de todas as telas; os balões ficam
          // translúcidos por cima (ver AppTheme e AppBackground).
          builder: (context, child) => Stack(
            children: [
              const AppBackground(),
              if (child != null) child,
            ],
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
