import 'package:flutter/material.dart';

import '../../models/solicitacao.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';
import '../common/formatos.dart';

class DecisaoSheet extends StatefulWidget {
  const DecisaoSheet({
    super.key,
    required this.solicitacao,
    required this.aceitarInicial,
    required this.onAceitar,
    required this.onRecusar,
  });

  final Solicitacao solicitacao;
  final bool aceitarInicial;
  final Future<String?> Function(DateTime quando) onAceitar;
  final Future<String?> Function(String motivo) onRecusar;

  @override
  State<DecisaoSheet> createState() => _DecisaoSheetState();
}

class _DecisaoSheetState extends State<DecisaoSheet> {
  late bool _aceitar = widget.aceitarInicial;
  late DateTime? _data = widget.solicitacao.dataDesejada;
  TimeOfDay _hora = const TimeOfDay(hour: 8, minute: 0);
  final _motivo = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDate: (_data != null && _data!.isAfter(hoje)) ? _data! : hoje,
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _escolherHora() async {
    final h = await showTimePicker(context: context, initialTime: _hora);
    if (h != null) setState(() => _hora = h);
  }

  Future<void> _confirmar() async {
    String? erro;
    if (_aceitar && _data == null) erro = 'Escolha a data.';
    if (!_aceitar && _motivo.text.trim().isEmpty) erro = 'Informe o motivo.';
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final d = _data;
    final r = _aceitar && d != null
        ? await widget.onAceitar(
            DateTime(d.year, d.month, d.day, _hora.hour, _hora.minute))
        : await widget.onRecusar(_motivo.text.trim());
    if (!mounted) return;
    if (r == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _enviando = false;
        _erro = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.solicitacao.assunto,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleLarge),
            Text(widget.solicitacao.tipo, style: text.bodyMedium),
            const SizedBox(height: AppTheme.spacingMd),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Aceitar')),
                ButtonSegment(value: false, label: Text('Recusar')),
              ],
              selected: {_aceitar},
              onSelectionChanged: (s) => setState(() => _aceitar = s.first),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (_aceitar) ...[
              OutlinedButton.icon(
                onPressed: _escolherData,
                icon: const Icon(Icons.event_rounded),
                label: Text(_data == null ? 'Escolher data' : dataCurta(_data!)),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              OutlinedButton.icon(
                onPressed: _escolherHora,
                icon: const Icon(Icons.schedule_rounded),
                label: Text('Horário: ${_hora.format(context)}'),
              ),
            ] else
              TextField(
                controller: _motivo,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Motivo da recusa (o agente verá)'),
              ),
            if (_erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: _erro!),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton(
              onPressed: _enviando ? null : _confirmar,
              child: Text(_enviando
                  ? 'Salvando…'
                  : (_aceitar ? 'Confirmar agendamento' : 'Confirmar recusa')),
            ),
          ],
        ),
      ),
    );
  }
}
