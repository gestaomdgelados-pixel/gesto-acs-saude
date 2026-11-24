import 'package:flutter/material.dart';

import '../../models/membro.dart';
import '../../models/vacina.dart';
import '../../theme/theme.dart';
import 'vacina_item_tile.dart';

class VacinaMembroCard extends StatelessWidget {
  const VacinaMembroCard({
    super.key,
    required this.membro,
    required this.itens,
    required this.nomeFamilia,
    required this.onAcao,
  });

  final Membro membro;
  final List<VacinaItem> itens;
  final String nomeFamilia;
  final void Function(VacinaItem item, AcaoVacina acao) onAcao;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final futuras = itens.where((i) => !i.concluida).toList();
    final concluidas = itens.where((i) => i.concluida).toList();
    final secoes = [('Futuras', futuras), ('Concluídas', concluidas)];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Card(
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(membro.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            'Família $nomeFamilia · ${futuras.length} a fazer · ${concluidas.length} concluídas',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            for (final (titulo, lista) in secoes)
              if (lista.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd, AppTheme.spacingSm, AppTheme.spacingMd, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(titulo, style: text.labelLarge),
                  ),
                ),
                for (final item in lista)
                  VacinaItemTile(
                    item: item,
                    onAcao: (acao) => onAcao(item, acao),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}
