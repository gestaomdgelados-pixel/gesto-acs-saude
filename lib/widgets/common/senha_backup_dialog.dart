import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SenhaBackupDialog extends StatefulWidget {
  const SenhaBackupDialog({super.key, required this.criar});

  /// true ao criar (pede confirmação); false ao usar um backup.
  final bool criar;

  @override
  State<SenhaBackupDialog> createState() => _SenhaBackupDialogState();
}

class _SenhaBackupDialogState extends State<SenhaBackupDialog> {
  final _form = GlobalKey<FormState>();
  final _senha = TextEditingController();
  final _conf = TextEditingController();
  bool _oculta = true;

  @override
  void dispose() {
    _senha.dispose();
    _conf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final criar = widget.criar;
    return AlertDialog(
      title: Text(criar ? 'Senha do backup' : 'Senha do arquivo'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(criar
                  ? 'Escolha uma senha para proteger o arquivo. Ela será pedida para usar este backup.'
                  : 'Digite a senha escolhida quando o backup foi criado. O que estiver no backup e faltar no app será recuperado.'),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _senha,
                obscureText: _oculta,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    tooltip: _oculta ? 'Mostrar senha' : 'Esconder senha',
                    icon: Icon(_oculta
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _oculta = !_oculta),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Use pelo menos 6 caracteres'
                    : null,
              ),
              if (criar) ...[
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  controller: _conf,
                  obscureText: _oculta,
                  decoration: const InputDecoration(labelText: 'Repita a senha'),
                  validator: (v) =>
                      v != _senha.text ? 'As senhas não são iguais' : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, _senha.text);
            }
          },
          child: Text(criar ? 'Criar backup' : 'Usar backup'),
        ),
      ],
    );
  }
}
