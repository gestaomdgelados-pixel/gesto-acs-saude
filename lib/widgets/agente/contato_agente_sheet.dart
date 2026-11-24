import 'package:flutter/material.dart';

import '../../models/agente_contato.dart';
import '../../theme/theme.dart';

class ContatoAgenteSheet extends StatefulWidget {
  const ContatoAgenteSheet({super.key, this.inicial, required this.onSalvar});

  final AgenteContato? inicial;
  final Future<String?> Function(AgenteContato) onSalvar;

  @override
  State<ContatoAgenteSheet> createState() => _ContatoAgenteSheetState();
}

class _ContatoAgenteSheetState extends State<ContatoAgenteSheet> {
  late final _area = TextEditingController(text: widget.inicial?.area ?? '');
  late final _tel = TextEditingController(text: widget.inicial?.telefone ?? '');
  late final _zap = TextEditingController(text: widget.inicial?.whatsapp ?? '');
  late final _dias = TextEditingController(text: widget.inicial?.dias ?? '');
  late final _horas =
      TextEditingController(text: widget.inicial?.horarios ?? '');
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    for (final c in [_area, _tel, _zap, _dias, _horas]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _v(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(AgenteContato(
      area: _v(_area),
      telefone: _v(_tel),
      whatsapp: _v(_zap),
      dias: _v(_dias),
      horarios: _v(_horas),
    ));
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _salvando = false;
      _erro = erro;
    });
  }

  Widget _campo(TextEditingController c, String rotulo,
          {TextInputType teclado = TextInputType.text, String? dica}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        child: TextField(
          controller: c,
          keyboardType: teclado,
          decoration: InputDecoration(labelText: rotulo, hintText: dica),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final erro = _erro;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Meu contato para os moradores',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingMd),
            _campo(_area, 'Área de atuação', dica: 'Ex.: Microárea 3 - Centro'),
            _campo(_tel, 'Telefone', teclado: TextInputType.phone),
            _campo(_zap, 'WhatsApp', teclado: TextInputType.phone),
            _campo(_dias, 'Dias de atendimento', dica: 'Ex.: Segunda a sexta'),
            _campo(_horas, 'Horários de atendimento', dica: 'Ex.: 8h às 12h'),
            if (erro != null)
              Text(erro,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: AppTheme.spacingSm),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando…' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
