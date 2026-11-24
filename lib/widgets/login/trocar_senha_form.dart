import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/error_banner.dart';

class TrocarSenhaForm extends StatefulWidget {
  const TrocarSenhaForm({super.key, required this.onSalvar});

  final Future<String?> Function(String nova) onSalvar;

  @override
  State<TrocarSenhaForm> createState() => _TrocarSenhaFormState();
}

class _TrocarSenhaFormState extends State<TrocarSenhaForm> {
  final _form = GlobalKey<FormState>();
  final _nova = TextEditingController();
  final _confirma = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nova.dispose();
    _confirma.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(_nova.text);
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = erro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nova,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Nova senha', prefixIcon: Icon(Icons.lock_rounded)),
            validator: (v) => (v == null || v.length < 8)
                ? 'Use pelo menos 8 caracteres'
                : (v == '251540@' ? 'Escolha uma senha diferente da inicial' : null),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextFormField(
            controller: _confirma,
            obscureText: true,
            onFieldSubmitted: (_) => _salvar(),
            decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: Icon(Icons.lock_reset_rounded)),
            validator: (v) => v != _nova.text ? 'As senhas não conferem' : null,
          ),
          if (_erro != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            ErrorBanner(mensagem: _erro!),
          ],
          const SizedBox(height: AppTheme.spacingLg),
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: Text(_salvando ? 'Salvando…' : 'Salvar e continuar'),
          ),
        ],
      ),
    );
  }
}
