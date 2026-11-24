import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/login/trocar_senha_form.dart';

class TrocarSenhaScreen extends StatelessWidget {
  const TrocarSenhaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mudar minha senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: ResponsiveLayout.constrain(
            maxWidth: AppTheme.formMaxWidth,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Olá, ${session.perfil?.nome ?? ''}!',
                    style: text.headlineSmall),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Se quiser, defina uma nova senha para o seu login. '
                  'Você continua conectado depois da troca.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                TrocarSenhaForm(
                  onSalvar: (nova) async {
                    final erro =
                        await context.read<SessionProvider>().trocarSenha(nova);
                    if (erro == null && context.mounted) context.pop();
                    return erro;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
