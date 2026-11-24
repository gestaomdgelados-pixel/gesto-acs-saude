import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme.dart';

/// Escolha da fonte (5 opções), do estilo de cor (fixa ou degradê) e da paleta.
class AparenciaCard extends StatelessWidget {
  const AparenciaCard({
    super.key,
    required this.fonte,
    required this.cor,
    required this.degrade,
    required this.transparencia,
    required this.onFonte,
    required this.onCor,
    required this.onDegrade,
    required this.onTransparencia,
  });

  final String fonte;
  final Color cor;
  final bool degrade;

  /// 0 = balão bem transparente, 1 = balão sólido.
  final double transparencia;
  final ValueChanged<String> onFonte;
  final ValueChanged<Color> onCor;
  final ValueChanged<bool> onDegrade;
  final ValueChanged<double> onTransparencia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = theme.colorScheme;
    final app = theme.extension<AppColorsExtension>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Letras', style: text.titleMedium),
            const SizedBox(height: AppTheme.spacingSm),
            for (final f in AppTheme.fontes)
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: f,
                groupValue: fonte,
                onChanged: (v) => v == null ? null : onFonte(v),
                title: Text('Saúde para todos',
                    style: GoogleFonts.getFont(f, textStyle: text.titleMedium)),
                subtitle: Text(f, style: text.bodySmall),
              ),
            const Divider(height: AppTheme.spacingLg),
            Text('Cores', style: text.titleMedium),
            const SizedBox(height: AppTheme.spacingSm),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    icon: Icon(Icons.circle),
                    label: Text('Cores fixas')),
                ButtonSegment(
                    value: true,
                    icon: Icon(Icons.gradient_rounded),
                    label: Text('Degradê')),
              ],
              selected: {degrade},
              onSelectionChanged: (s) => onDegrade(s.first),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Paleta', style: text.bodyMedium),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: [
                for (final c in AppTheme.paletaCores)
                  _CorBolinha(
                    cor: c,
                    degrade: degrade,
                    selecionada: c.toARGB32() == cor.toARGB32(),
                    corBorda: colors.onSurface,
                    corCheck: app.onBrand,
                    onTap: () => onCor(c),
                  ),
              ],
            ),
            const Divider(height: AppTheme.spacingLg),
            Text('Transparência dos balões', style: text.titleMedium),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Deixa os cartões e avisos do app mais ou menos transparentes '
              'sobre o fundo.',
              style: text.bodySmall?.copyWith(color: app.subtleText),
            ),
            Row(
              children: [
                const Icon(Icons.blur_on_rounded),
                Expanded(
                  child: Slider(
                    value: transparencia,
                    min: AppTheme.opacidadeBalaoMinima,
                    max: 1.0,
                    label: '${(transparencia * 100).round()}%',
                    onChanged: onTransparencia,
                  ),
                ),
                const Icon(Icons.circle_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CorBolinha extends StatelessWidget {
  const _CorBolinha({
    required this.cor,
    required this.degrade,
    required this.selecionada,
    required this.corBorda,
    required this.corCheck,
    required this.onTap,
  });

  final Color cor;
  final bool degrade;
  final bool selecionada;
  final Color corBorda;
  final Color corCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: selecionada ? 'Cor escolhida' : 'Escolher esta cor',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXs),
          child: Container(
            width: AppTheme.colorDot,
            height: AppTheme.colorDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor,
              gradient: degrade
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cor, AppTheme.fimDegrade(cor)],
                    )
                  : null,
              border: selecionada
                  ? Border.all(color: corBorda, width: AppTheme.borderSelected)
                  : null,
            ),
            child: selecionada
                ? Icon(Icons.check_rounded,
                    color: corCheck, size: AppTheme.iconSm)
                : null,
          ),
        ),
      ),
    );
  }
}
