import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'formatos.dart';

class CampoData extends StatelessWidget {
  const CampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.primeira,
    required this.ultima,
    required this.onChanged,
  });

  final String rotulo;
  final DateTime? valor;
  final DateTime primeira;
  final DateTime ultima;
  final ValueChanged<DateTime> onChanged;

  Future<void> _escolher(BuildContext context) async {
    final base = valor ?? DateTime.now();
    final inicial = base.isBefore(primeira)
        ? primeira
        : (base.isAfter(ultima) ? ultima : base);
    final d = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primeira,
      lastDate: ultima,
    );
    if (d != null) onChanged(d);
  }

  @override
  Widget build(BuildContext context) {
    final v = valor;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        onTap: () => _escolher(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: rotulo,
            suffixIcon: const Icon(Icons.event_rounded),
          ),
          child: Text(v == null ? 'Selecionar data' : dataCurta(v)),
        ),
      ),
    );
  }
}
