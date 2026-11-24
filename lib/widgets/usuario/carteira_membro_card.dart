import 'package:flutter/material.dart';

import '../../models/carteira.dart';
import '../../models/vacina.dart';
import '../../theme/theme.dart';
import 'vacina_carteira_tile.dart';

class CarteiraMembroCard extends StatelessWidget {
  const CarteiraMembroCard({
    super.key,
    required this.nome,
    required this.detalhe,
    required this.itens,
  });

  final String nome;
  final String detalhe;
  final List<VacinaItem> itens;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final app = Theme.of(context).extension<AppColorsExtension>()!;
    final ordenados = [...itens]
      ..sort((a, b) => a.situacao.index.compareTo(b.situacao.index));
    int conta(SituacaoVacina s) => itens.where((i) => i.situacao == s).length;
    final resumo = [
      for (final s in SituacaoVacina.values)
        if (conta(s) > 0) '${conta(s)} ${s.rotulo.toLowerCase()}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(nome, style: text.titleMedium),
              if (detalhe.isNotEmpty)
                Text(detalhe,
                    style: text.bodySmall?.copyWith(color: app.subtleText)),
              if (resumo.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(resumo, style: text.labelLarge),
              ],
              const Divider(),
              if (ordenados.isEmpty)
                Text('Nenhuma vacina cadastrada pelo agente.',
                    style: text.bodyMedium?.copyWith(color: app.subtleText)),
              for (final i in ordenados) VacinaCarteiraTile(item: i),
            ],
          ),
        ),
      ),
    );
  }
}
