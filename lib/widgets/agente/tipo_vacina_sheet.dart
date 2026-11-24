import 'package:flutter/material.dart';

import '../../models/parse.dart';
import '../../theme/theme.dart';
import '../common/campo_texto.dart';
import '../common/error_banner.dart';

class TipoVacinaSheet extends StatefulWidget {
  const TipoVacinaSheet({super.key, required this.onSalvar});

  final Future<String?> Function(String nome, String? descricao) onSalvar;

  @override
  State<TipoVacinaSheet> createState() => _TipoVacinaSheetState();
}

class _TipoVacinaSheetState extends State<TipoVacinaSheet> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro =
        await widget.onSalvar(_nome.text.trim(), textoOuNulo(_descricao.text));
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
              Text('Nova vacina', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              CampoTexto(
                  controller: _nome,
                  rotulo: 'Nome da vacina (ex.: Gripe 2026)',
                  obrigatorio: true),
              CampoTexto(
                  controller: _descricao, rotulo: 'Descrição (opcional)', linhas: 2),
              if (mensagem != null) ...[
                ErrorBanner(mensagem: mensagem),
                const SizedBox(height: AppTheme.spacingMd),
              ],
              FilledButton(
                onPressed: _enviando ? null : _salvar,
                child: Text(_enviando ? 'Salvando…' : 'Cadastrar vacina'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
