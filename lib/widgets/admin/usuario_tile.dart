import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/status_chip.dart';

class UsuarioTile extends StatelessWidget {
  const UsuarioTile({
    super.key,
    required this.perfil,
    required this.ehVoce,
    required this.onEditar,
    required this.onSenha,
    required this.onExcluir,
  });

  final Profile perfil;
  final bool ehVoce;
  final VoidCallback onEditar;
  final VoidCallback onSenha;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final inicial = perfil.nome.isEmpty ? '?' : perfil.nome[0].toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppTheme.avatarMd / 2,
              backgroundColor: colors.primaryContainer,
              child: Text(inicial,
                  style: text.titleMedium
                      ?.copyWith(color: colors.onPrimaryContainer)),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ehVoce ? '${perfil.nome} (você)' : perfil.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium),
                  Text('@${perfil.usuario}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall),
                  const SizedBox(height: AppTheme.spacingXs),
                  Wrap(
                    spacing: AppTheme.spacingXs,
                    runSpacing: AppTheme.spacingXs,
                    children: [
                      StatusChip(rotulo: perfil.perfil.rotulo, tom: StatusTom.neutro),
                      if (!perfil.ativo)
                        const StatusChip(rotulo: 'Desativado', tom: StatusTom.perigo),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<int>(
              tooltip: 'Ações',
              onSelected: (v) => switch (v) {
                0 => onEditar(),
                1 => onSenha(),
                _ => onExcluir(),
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 0, child: Text('Editar')),
                const PopupMenuItem(value: 1, child: Text('Trocar senha')),
                PopupMenuItem(
                    value: 2, enabled: !ehVoce, child: const Text('Excluir')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
