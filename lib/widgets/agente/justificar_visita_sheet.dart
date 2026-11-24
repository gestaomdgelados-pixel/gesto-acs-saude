import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/campo_texto.dart';
import '../common/error_banner.dart';

class JustificarVisitaSheet extends StatefulWidget {
  const JustificarVisitaSheet({super.key, required this.onSalvar});

  final Future<String?> Function(String justificativa) onSalvar;

  @override
  State<JustificarVisitaSheet> createState() => _JustificarVisitaSheetState();
}

class _JustificarVisitaSheetState extends State<JustificarVisitaSheet> {
  final _form = GlobalKey<FormState>();
  final _texto = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(_texto.text.trim());
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
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Justificar visita', style: text.titleLarge),
              const SizedBox(height: AppTheme.spacingXs),
              Text('A visita não pode ser apagada. Explique por que ela não foi realizada.',
                  style: text.bodyMedium),
              const SizedBox(height: AppTheme.spacingMd),
              CampoTexto(
                  controller: _texto,
                  rotulo: 'Motivo',
                  obrigatorio: true,
                  linhas: 3),
              if (mensagem != null) ...[
                ErrorBanner(mensagem: mensagem),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              FilledButton(
                onPressed: _enviando ? null : _salvar,
                child: Text(_enviando ? 'Salvando…' : 'Salvar justificativa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
