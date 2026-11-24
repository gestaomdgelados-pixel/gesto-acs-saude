import 'package:flutter/material.dart';

import '../../models/aviso.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';
import '../common/formatos.dart';

class AvisoFormSheet extends StatefulWidget {
  const AvisoFormSheet({super.key, required this.onSalvar});

  final Future<String?> Function(AvisoRascunho r) onSalvar;

  @override
  State<AvisoFormSheet> createState() => _AvisoFormSheetState();
}

class _AvisoFormSheetState extends State<AvisoFormSheet> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _desc = TextEditingController();
  String _tipo = 'reuniao';
  DateTime _quando = DateTime.now().add(const Duration(days: 1));
  String _cor = AppTheme.campanhaCores.first;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _titulo.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _escolherQuando() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: hoje.subtract(const Duration(days: 1)),
      lastDate: hoje.add(const Duration(days: 365)),
      initialDate: _quando,
    );
    if (d == null || !mounted) return;
    final h = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_quando));
    setState(() => _quando =
        DateTime(d.year, d.month, d.day, h?.hour ?? 8, h?.minute ?? 0));
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(AvisoRascunho(
      tipo: _tipo,
      titulo: _titulo.text.trim(),
      descricao: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      data: _tipo == 'aviso' ? DateTime.now() : _quando,
      cor: _tipo == 'campanha' ? _cor : null,
    ));
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final ajuda = switch (_tipo) {
      'reuniao' => 'Aparece na tela de reuniões de todos os agentes.',
      'aviso' => 'Aviso para todos os agentes de saúde.',
      _ => 'Campanha para TODOS os logins, inclusive moradores.',
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Publicar', style: text.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'reuniao', label: Text('Reunião')),
                  ButtonSegment(value: 'aviso', label: Text('Aviso')),
                  ButtonSegment(value: 'campanha', label: Text('Campanha')),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(ajuda, style: text.bodySmall),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _desc,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              if (_tipo == 'reuniao')
                OutlinedButton.icon(
                  onPressed: _escolherQuando,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(dataHora(_quando)),
                ),
              if (_tipo == 'campanha')
                Wrap(
                  spacing: AppTheme.spacingSm,
                  children: [
                    for (final c in AppTheme.campanhaCores)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _cor = c),
                        child: Container(
                          width: AppTheme.colorDot,
                          height: AppTheme.colorDot,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.fromHex(c, colors.primary),
                            border: Border.all(
                              color: c == _cor ? colors.onSurface : colors.outlineVariant,
                              width: c == _cor
                                  ? AppTheme.borderSelected * 1.5
                                  : AppTheme.borderDefault,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              if (_erro != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                ErrorBanner(mensagem: _erro!),
              ],
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: Text(_salvando ? 'Publicando…' : 'Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
