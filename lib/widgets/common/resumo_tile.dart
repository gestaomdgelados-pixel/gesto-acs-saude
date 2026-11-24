import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ResumoTile extends StatelessWidget {
  const ResumoTile({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sub = subtitulo;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            child: Icon(icone),
          ),
          title: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: sub == null
              ? null
              : Text(sub, maxLines: 3, overflow: TextOverflow.ellipsis),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
