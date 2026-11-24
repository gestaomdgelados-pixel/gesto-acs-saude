import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/membro.dart';
import '../../providers/morador_provider.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/usuario/carteira_membro_card.dart';

const semVinculo =
    'Seu cadastro ainda não foi ligado a uma família. Peça ao seu agente de saúde para vincular o seu login.';

class CarteiraScreen extends StatelessWidget {
  const CarteiraScreen({super.key});

  String _detalhe(Membro m) {
    final idade = m.idade;
    return [
      if (m.parentesco != null) m.parentesco!,
      if (idade != null) '$idade anos',
      if (m.gestante) 'Gestante',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MoradorProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Carteira de vacinação')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: m.carregar,
          children: [
            AsyncSection(
              carregando: m.carregando,
              erro: m.erro,
              vazio: m.membros.isEmpty,
              textoVazio: m.vinculado
                  ? 'Nenhuma pessoa cadastrada na sua família.'
                  : semVinculo,
              onTentarNovamente: m.carregar,
              child: Column(
                children: [
                  for (final p in m.membros)
                    CarteiraMembroCard(
                      nome: p.nome,
                      detalhe: _detalhe(p),
                      itens: m.carteiraDe(p.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
