import 'package:flutter/material.dart';

/// Plano de fundo do app: a imagem de campo ensolarado quando o tema claro
/// está ativo, e a casinha à noite quando o tema escuro está ativo. Fica
/// atrás de todas as telas; os "balões" (cartões, abas, formulários) ficam
/// translúcidos por cima, com a transparência ajustável em Configurações.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  static const _fundoDia = 'assets/images/fundo_dia.jpg';
  static const _fundoNoite = 'assets/images/fundo_noite.jpg';

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Image.asset(
          escuro ? _fundoNoite : _fundoDia,
          key: ValueKey(escuro),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
