import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/campo_data.dart';
import '../common/campo_texto.dart';
import '../common/error_banner.dart';

class ConcluirVacinaSheet extends StatefulWidget {
  const ConcluirVacinaSheet({
    super.key,
    required this.titulo,
    required this.onConfirmar,
  });

  final String titulo;
  final Future<String?> Function(DateTime data, String aplicadoPor, String lote)
      onConfirmar;

  @override
  State<ConcluirVacinaSheet> createState() => _ConcluirVacinaSheetState();
}

class _ConcluirVacinaSheetState extends State<ConcluirVacinaSheet> {
  final _form = GlobalKey<FormState>();
  final _quem = TextEditingController();
  final _lote = TextEditingController();
  late DateTime _data = _hoje();
  bool _enviando = false;
  String? _erro;

  static DateTime _hoje() {
    final h = DateTime.now();
    return DateTime(h.year, h.month, h.day);
  }

  @override
  void dispose() {
    _quem.dispose();
    _lote.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro =
        await widget.onConfirmar(_data, _quem.text.trim(), _lote.text.trim());
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
              Text('Concluir vacina', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingXs),
              Text(widget.titulo),
              const SizedBox(height: AppTheme.spacingMd),
              CampoData(
                rotulo: 'Dia da aplicação *',
                valor: _data,
                primeira: DateTime(2000),
                ultima: _hoje(),
                onChanged: (d) => setState(() => _data = d),
              ),
              CampoTexto(
                  controller: _quem, rotulo: 'Quem aplicou', obrigatorio: true),
              CampoTexto(controller: _lote, rotulo: 'Lote', obrigatorio: true),
              if (mensagem != null) ...[
                ErrorBanner(mensagem: mensagem),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              FilledButton(
                onPressed: _enviando ? null : _confirmar,
                child: Text(_enviando ? 'Salvando…' : 'Concluir vacina'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
