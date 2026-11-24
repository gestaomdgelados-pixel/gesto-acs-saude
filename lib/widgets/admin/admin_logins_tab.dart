import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/async_section.dart';
import '../common/refreshable_list.dart';
import '../common/section_header.dart';
import 'usuario_tile.dart';

class AdminLoginsTab extends StatelessWidget {
  const AdminLoginsTab({
    super.key,
    required this.usuarios,
    required this.carregando,
    required this.erro,
    required this.idAtual,
    required this.onAtualizar,
    required this.onEditar,
    required this.onSenha,
    required this.onExcluir,
  });

  final List<Profile> usuarios;
  final bool carregando;
  final String? erro;
  final String? idAtual;
  final Future<void> Function() onAtualizar;
  final ValueChanged<Profile> onEditar;
  final ValueChanged<Profile> onSenha;
  final ValueChanged<Profile> onExcluir;

  @override
  Widget build(BuildContext context) {
    return RefreshableList(
      onRefresh: onAtualizar,
      children: [
        SectionHeader(
            titulo: 'Logins (${usuarios.length})', icone: Icons.people_rounded),
        AsyncSection(
          carregando: carregando,
          erro: erro,
          vazio: usuarios.isEmpty,
          textoVazio: 'Nenhum login cadastrado.',
          onTentarNovamente: onAtualizar,
          child: Column(
            children: [
              for (final u in usuarios)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: UsuarioTile(
                    perfil: u,
                    ehVoce: u.id == idAtual,
                    onEditar: () => onEditar(u),
                    onSenha: () => onSenha(u),
                    onExcluir: () => onExcluir(u),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
