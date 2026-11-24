import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'error_banner.dart';

class PermissoesCard extends StatelessWidget {
  const PermissoesCard({
    super.key,
    required this.internet,
    required this.notificacoes,
    required this.arquivos,
    required this.ocupado,
    required this.onInternet,
    required this.onNotificacoes,
    required this.onArquivos,
    this.erro,
  });

  final bool? internet;
  final bool? notificacoes;
  final bool? arquivos;
  final bool ocupado;
  final VoidCallback onInternet;
  final VoidCallback onNotificacoes;
  final VoidCallback onArquivos;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ocupado) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppTheme.spacingSm),
            ],
            _Linha(
              icone: Icons.wifi_rounded,
              titulo: 'Acesso à internet',
              permitido: internet,
              textoNulo: 'Ainda não verificado',
              botao: 'Verificar',
              onPressed: ocupado ? null : onInternet,
            ),
            _Linha(
              icone: Icons.notifications_active_rounded,
              titulo: 'Notificações do celular',
              permitido: notificacoes,
              textoNulo: 'Disponível só no celular',
              botao: 'Autorizar',
              onPressed: ocupado || notificacoes == null || notificacoes!
                  ? null
                  : onNotificacoes,
            ),
            _Linha(
              icone: Icons.folder_open_rounded,
              titulo: 'Acesso aos arquivos',
              permitido: arquivos,
              textoNulo: 'Liberado pelo celular a cada arquivo escolhido',
              botao: 'Autorizar',
              onPressed: ocupado ? null : onArquivos,
            ),
            if (erro != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              ErrorBanner(mensagem: erro!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.titulo,
    required this.permitido,
    required this.textoNulo,
    required this.botao,
    required this.onPressed,
  });

  final IconData icone;
  final String titulo;
  final bool? permitido;
  final String textoNulo;
  final String botao;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = theme.extension<AppColorsExtension>()!;
    final (status, cor) = switch (permitido) {
      true => ('Permitido', app.success),
      false => ('Não permitido', app.danger),
      null => (textoNulo, app.subtleText),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          Icon(icone, color: theme.colorScheme.primary),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: theme.textTheme.titleSmall),
                Text(status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          FilledButton.tonal(onPressed: onPressed, child: Text(botao)),
        ],
      ),
    );
  }
}
