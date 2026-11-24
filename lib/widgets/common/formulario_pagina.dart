import 'package:flutter/material.dart';

import '../../theme/responsive_layout.dart';
import '../../theme/theme.dart';
import 'error_banner.dart';

class FormularioPagina extends StatelessWidget {
  const FormularioPagina({
    super.key,
    required this.titulo,
    required this.formKey,
    required this.children,
    required this.salvando,
    required this.onSalvar,
    this.erro,
    this.rotuloSalvar = 'Salvar',
  });

  final String titulo;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final bool salvando;
  final VoidCallback onSalvar;
  final String? erro;
  final String rotuloSalvar;

  @override
  Widget build(BuildContext context) {
    final mensagem = erro;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: ResponsiveLayout.getPadding(context),
            child: ResponsiveLayout.constrain(
              maxWidth: AppTheme.formMaxWidth,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...children,
                  if (mensagem != null) ...[
                    ErrorBanner(mensagem: mensagem),
                    const SizedBox(height: AppTheme.spacingMd),
                  ],
                  FilledButton(
                    onPressed: salvando ? null : onSalvar,
                    child: Text(salvando ? 'Salvando…' : rotuloSalvar),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
