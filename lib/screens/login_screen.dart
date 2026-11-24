import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/login/login_form.dart';
import '../widgets/login/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final app = Theme.of(context).extension<AppColorsExtension>()!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [app.brandStart, app.brandEnd],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveLayout.getPadding(context),
                child: ResponsiveLayout.constrain(
                  maxWidth: AppTheme.formMaxWidth,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: AppTheme.spacingLg),
                      LoginForm(
                        usuarioInicial: session.ultimoUsuario,
                        ocupado: session.ocupado,
                        erro: session.erro,
                        onEntrar: (u, s) =>
                            context.read<SessionProvider>().entrar(u, s),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
