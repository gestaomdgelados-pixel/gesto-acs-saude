import 'package:flutter/material.dart';

class MotivoDialog extends StatefulWidget {
  const MotivoDialog({super.key, required this.titulo});

  final String titulo;

  @override
  State<MotivoDialog> createState() => _MotivoDialogState();
}

class _MotivoDialogState extends State<MotivoDialog> {
  final _form = GlobalKey<FormState>();
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _motivo,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Motivo'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Informe o motivo' : null,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar')),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, _motivo.text.trim());
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
