import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/error_banner.dart';

class SenhaDialog extends StatefulWidget {
  const SenhaDialog({super.key, required this.nome, required this.onSalvar});

  final String nome;
  final Future<String?> Function(String senha) onSalvar;

  @override
  State<SenhaDialog> createState() => _SenhaDialogState();
}

class _SenhaDialogState extends State<SenhaDialog> {
  final _senha = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_senha.text.length < 6) {
      setState(() => _erro = 'Mínimo de 6 caracteres.');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(_senha.text);
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nova senha para ${widget.nome}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _senha,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nova senha'),
          ),
          if (_erro != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            ErrorBanner(mensagem: _erro!),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: _salvando ? null : () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        TextButton(
            onPressed: _salvando ? null : _salvar,
            child: Text(_salvando ? 'Salvando…' : 'Salvar')),
      ],
    );
  }
}
