import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/morador_provider.dart';
import '../../widgets/common/async_section.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/usuario/contato_agente_card.dart';

class ContatoAgenteScreen extends StatelessWidget {
  const ContatoAgenteScreen({super.key});

  static String _digitos(String t) => t.replaceAll(RegExp(r'\D'), '');

  Future<void> _abrir(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        mostrarMensagem(context, 'Não foi possível abrir neste aparelho.',
            erro: true);
      }
    } catch (e) {
      if (context.mounted) {
        mostrarMensagem(context, 'Não foi possível abrir: $e', erro: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MoradorProvider>();
    final c = m.contato;
    return Scaffold(
      appBar: AppBar(title: const Text('Contato do agente')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: m.carregar,
          children: [
            AsyncSection(
              carregando: m.carregando,
              erro: m.erro,
              vazio: c == null,
              textoVazio:
                  'O administrador ainda não definiu o seu agente de saúde.',
              onTentarNovamente: m.carregar,
              child: c == null
                  ? const SizedBox.shrink()
                  : ContatoAgenteCard(
                      contato: c,
                      onLigar: (t) =>
                          _abrir(context, Uri.parse('tel:${_digitos(t)}')),
                      onWhatsApp: (t) {
                        final d = _digitos(t);
                        _abrir(context,
                            Uri.parse('https://wa.me/${d.length <= 11 ? '55$d' : d}'));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
