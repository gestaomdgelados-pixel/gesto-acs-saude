import 'package:flutter/material.dart';

import '../../theme/theme.dart';

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto,
          style: TextStyle(color: erro ? colors.onError : colors.onInverseSurface)),
      backgroundColor: erro ? colors.error : colors.inverseSurface,
      duration: Duration(seconds: erro ? 6 : 3),
    ));
}

Future<bool> confirmar(
    BuildContext context, String titulo, String mensagem) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
            minimumSize: const Size(0, AppTheme.avatarMd),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return r == true;
}
