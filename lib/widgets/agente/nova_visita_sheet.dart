import 'package:flutter/material.dart';

import '../../models/familia.dart';
import '../../theme/theme.dart';
import '../common/campo_data.dart';
import '../common/campo_texto.dart';
import '../common/error_banner.dart';

class NovaVisitaSheet extends StatefulWidget {
  const NovaVisitaSheet({
    super.key,
    required this.familias,
    required this.onAgendar,
  });

  final List<Familia> familias;
  final Future<String?> Function(String familiaId, DateTime quando, String motivo)
      onAgendar;

  @override
  State<NovaVisitaSheet> createState() => _NovaVisitaSheetState();
}

class _NovaVisitaSheetState extends State<NovaVisitaSheet> {
  final _form = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  String? _familiaId;
  late DateTime _data = _hoje();
  TimeOfDay _hora = const TimeOfDay(hour: 9, minute: 0);
  bool _enviando = false;
  String? _erro;

  static DateTime _hoje() {
    final h = DateTime.now();
    return DateTime(h.year, h.month, h.day);
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _escolherHora() async {
    final h = await showTimePicker(context: context, initialTime: _hora);
    if (h != null) setState(() => _hora = h);
  }

  Future<void> _agendar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final quando =
        DateTime(_data.year, _data.month, _data.day, _hora.hour, _hora.minute);
    final erro =
        await widget.onAgendar(_familiaId!, quando, _motivo.text.trim());
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _enviando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mensagem = _erro;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Agendar visita', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Família *'),
                  items: [
                    for (final f in widget.familias)
                      DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.responsavel} - ${f.endereco}',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _familiaId = v),
                  validator: (v) => v == null ? 'Escolha a família' : null,
                ),
              ),
              CampoData(
                rotulo: 'Dia da visita *',
                valor: _data,
                primeira: _hoje(),
                ultima: _hoje().add(const Duration(days: 365)),
                onChanged: (d) => setState(() => _data = d),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: OutlinedButton.icon(
                  onPressed: _escolherHora,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text('Horário: ${_hora.format(context)}'),
                ),
              ),
              CampoTexto(
                  controller: _motivo,
                  rotulo: 'Motivo da visita',
                  obrigatorio: true,
                  linhas: 2),
              if (mensagem != null) ...[
                ErrorBanner(mensagem: mensagem),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              FilledButton(
                onPressed: _enviando ? null : _agendar,
                child: Text(_enviando ? 'Agendando…' : 'Agendar visita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
