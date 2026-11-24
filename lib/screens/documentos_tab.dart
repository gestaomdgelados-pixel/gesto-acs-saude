import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/documento.dart';
import '../providers/documentos_provider.dart';
import '../providers/session_provider.dart';
import '../theme/theme.dart';
import '../widgets/agente/enviar_documento_sheet.dart';
import '../widgets/common/async_section.dart';
import '../widgets/common/documento_tile.dart';
import '../widgets/common/feedback.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/section_header.dart';

/// Agente: documentos enviados. Gestão: documentos recebidos.
class DocumentosTab extends StatelessWidget {
  const DocumentosTab({super.key, required this.recebidos});

  final bool recebidos;

  Future<void> _enviar(BuildContext context) async {
    final prov = context.read<DocumentosProvider>();
    final nome = context.read<SessionProvider>().perfil?.nome ?? '';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EnviarDocumentoSheet(
        onEscolher: prov.escolherPdf,
        onEnviar: (a, usuario) => prov.enviar(a, usuario, nome),
      ),
    );
    if (ok == true && context.mounted) {
      mostrarMensagem(context, 'Documento enviado.');
    }
  }

  Future<void> _abrir(BuildContext context, Documento d) async {
    final r = await context.read<DocumentosProvider>().abrir(d);
    if (!context.mounted) return;
    final url = r.url;
    if (url == null) {
      mostrarMensagem(context, r.erro ?? 'Não foi possível abrir.', erro: true);
      return;
    }
    try {
      final abriu =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!abriu && context.mounted) {
        mostrarMensagem(context, 'Não foi possível abrir o PDF neste aparelho.',
            erro: true);
      }
    } catch (e) {
      if (context.mounted) {
        mostrarMensagem(context, 'Não foi possível abrir o PDF: $e', erro: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DocumentosProvider>();
    return RefreshableList(
      onRefresh: prov.carregar,
      children: [
        SectionHeader(
          titulo: recebidos ? 'Documentos recebidos' : 'Documentos enviados',
          icone: Icons.description_rounded,
        ),
        if (!recebidos) ...[
          FilledButton.icon(
            onPressed: () => _enviar(context),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Enviar documento'),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
        AsyncSection(
          carregando: prov.carregando,
          erro: prov.erro,
          vazio: prov.itens.isEmpty,
          textoVazio: recebidos
              ? 'Nenhum documento recebido.'
              : 'Nenhum documento enviado.',
          onTentarNovamente: prov.carregar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final d in prov.itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: DocumentoTile(
                    documento: d,
                    recebido: recebidos,
                    onAbrir: () => _abrir(context, d),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
