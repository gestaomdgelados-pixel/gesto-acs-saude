import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/familias_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';

class FamiliasTab extends StatefulWidget {
  const FamiliasTab({super.key});

  @override
  State<FamiliasTab> createState() => _FamiliasTabState();
}

class _FamiliasTabState extends State<FamiliasTab> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fam = context.watch<FamiliasProvider>();
    final termo = _busca.text.trim().toLowerCase();
    final lista = fam.familias
        .where((f) =>
            termo.isEmpty ||
            f.responsavel.toLowerCase().contains(termo) ||
            f.endereco.toLowerCase().contains(termo))
        .toList();

    return Scaffold(
      body: RefreshableList(
        onRefresh: fam.carregar,
        children: [
          TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Buscar família ou endereço',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AsyncSection(
            carregando: fam.carregando,
            erro: fam.erro,
            vazio: lista.isEmpty,
            textoVazio: fam.familias.isEmpty
                ? 'Nenhuma família cadastrada. Toque em "Nova família".'
                : 'Nenhuma família encontrada.',
            onTentarNovamente: fam.carregar,
            child: Column(
              children: [
                for (final f in lista)
                  ResumoTile(
                    icone: Icons.family_restroom_rounded,
                    titulo: f.responsavel,
                    subtitulo:
                        '${f.endereco}\n${fam.membrosDe(f.id).length} pessoa(s)',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/agente/familia/${f.id}'),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agente/nova-familia'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova família'),
      ),
    );
  }
}
