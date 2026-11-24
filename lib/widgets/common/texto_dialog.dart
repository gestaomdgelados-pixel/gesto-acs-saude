import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class TextoDialog extends StatefulWidget {
  const TextoDialog({
    super.key,
    required this.titulo,
    required this.rotulo,
    this.ajuda,
    this.inicial,
    this.botao = 'Salvar',
    this.teclado = TextInputType.text,
  });

  final String titulo;
  final String rotulo;
  final String? ajuda;
  final String? inicial;
  final String botao;
  final TextInputType teclado;

  @override
  State<TextoDialog> createState() => _TextoDialogState();
}

class _TextoDialogState extends State<TextoDialog> {
  late final _ctrl = TextEditingController(text: widget.inicial ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _ok() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    final ajuda = widget.ajuda;
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ajuda != null) ...[
            Text(ajuda),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: widget.teclado,
            decoration: InputDecoration(labelText: widget.rotulo),
            onSubmitted: (_) => _ok(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(onPressed: _ok, child: Text(widget.botao)),
      ],
    );
  }
}
