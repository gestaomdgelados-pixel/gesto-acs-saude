import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/error_banner.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.usuarioInicial,
    required this.ocupado,
    required this.erro,
    required this.onEntrar,
  });

  final String usuarioInicial;
  final bool ocupado;
  final String? erro;
  final void Function(String usuario, String senha) onEntrar;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  late final _usuario = TextEditingController(text: widget.usuarioInicial);
  final _senha = TextEditingController();
  bool _ocultar = true;

  @override
  void didUpdateWidget(covariant LoginForm old) {
    super.didUpdateWidget(old);
    if (_usuario.text.isEmpty && widget.usuarioInicial.isNotEmpty) {
      _usuario.text = widget.usuarioInicial;
    }
  }

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _enviar() {
    if (widget.ocupado || !_form.currentState!.validate()) return;
    widget.onEntrar(_usuario.text.trim(), _senha.text);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Entrar', style: text.titleLarge),
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  controller: _usuario,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o usuário' : null,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  controller: _senha,
                  obscureText: _ocultar,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _enviar(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(_ocultar
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha' : null,
                ),
                if (widget.erro != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  ErrorBanner(mensagem: widget.erro!),
                ],
                const SizedBox(height: AppTheme.spacingLg),
                FilledButton(
                  onPressed: widget.ocupado ? null : _enviar,
                  child: widget.ocupado
                      ? const SizedBox(
                          width: AppTheme.spinnerSize,
                          height: AppTheme.spinnerSize,
                          child: CircularProgressIndicator(
                              strokeWidth: AppTheme.spinnerStroke),
                        )
                      : const Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
