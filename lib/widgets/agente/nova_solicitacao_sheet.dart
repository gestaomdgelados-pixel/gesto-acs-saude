import 'package:flutter/material.dart';

import '../../models/solicitacao.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';
import '../common/formatos.dart';

class NovaSolicitacaoSheet extends StatefulWidget {
  const NovaSolicitacaoSheet({super.key, required this.onEnviar});

  final Future<String?> Function(SolicitacaoRascunho r) onEnviar;

  @override
  State<NovaSolicitacaoSheet> createState() => _NovaSolicitacaoSheetState();
}

class _NovaSolicitacaoSheetState extends State<NovaSolicitacaoSheet> {
  final _form = GlobalKey<FormState>();
  final _assunto = TextEditingController();
  final _obs = TextEditingController();
  String _tipo = 'Consulta';
  DateTime? _data;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _assunto.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDate: _data ?? hoje,
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.onEnviar(SolicitacaoRascunho(
      tipo: _tipo,
      assunto: _assunto.text.trim(),
      dataDesejada: _tipo == 'Consulta' ? _data : null,
      observacao: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
    ));
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
    final consulta = _tipo == 'Consulta';
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nova solicitação à gestão',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Consulta', label: Text('Consulta')),
                  ButtonSegment(value: 'Reclamação', label: Text('Reclamação')),
                  ButtonSegment(value: 'Outro', label: Text('Outro')),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _assunto,
                decoration: InputDecoration(
                  labelText: consulta
                      ? 'Especialidade e paciente (ex.: Dentista – Maria Silva)'
                      : 'Assunto',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null,
              ),
              if (consulta) ...[
                const SizedBox(height: AppTheme.spacingMd),
                OutlinedButton.icon(
                  onPressed: _escolherData,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(_data == null
                      ? 'Data desejada (opcional)'
                      : 'Data desejada: ${dataCurta(_data!)}'),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _obs,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Detalhes'),
              ),
              if (_erro != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                ErrorBanner(mensagem: _erro!),
              ],
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: _enviando ? null : _enviar,
                child: Text(_enviando ? 'Enviando…' : 'Enviar para a gestão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
