import 'package:flutter/material.dart';

import '../../models/arquivo_escolhido.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';

class EnviarDocumentoSheet extends StatefulWidget {
  const EnviarDocumentoSheet({
    super.key,
    required this.onEscolher,
    required this.onEnviar,
  });

  final Future<(ArquivoEscolhido?, String?)> Function() onEscolher;
  final Future<String?> Function(ArquivoEscolhido arquivo, String usuario)
      onEnviar;

  @override
  State<EnviarDocumentoSheet> createState() => _EnviarDocumentoSheetState();
}

class _EnviarDocumentoSheetState extends State<EnviarDocumentoSheet> {
  final _usuario = TextEditingController();
  ArquivoEscolhido? _arquivo;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _usuario.dispose();
    super.dispose();
  }

  Future<void> _escolher() async {
    final (arquivo, erro) = await widget.onEscolher();
    if (!mounted) return;
    setState(() {
      if (arquivo != null) _arquivo = arquivo;
      _erro = erro;
    });
  }

  Future<void> _enviar() async {
    final arquivo = _arquivo;
    if (arquivo == null) {
      setState(() => _erro = 'Escolha o PDF do documento.');
      return;
    }
    if (_usuario.text.trim().isEmpty) {
      setState(() => _erro = 'Digite o usuário da pessoa da gestão.');
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.onEnviar(arquivo, _usuario.text.trim());
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
    final text = Theme.of(context).textTheme;
    final arquivo = _arquivo;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enviar documento à gestão', style: text.titleLarge),
            const SizedBox(height: AppTheme.spacingMd),
            OutlinedButton.icon(
              onPressed: _enviando ? null : _escolher,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(arquivo == null ? 'Escolher PDF' : arquivo.nome,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _usuario,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Usuário da pessoa da gestão',
                helperText: 'Só essa pessoa vai receber. Digite o usuário exato.',
                helperMaxLines: 2,
                prefixText: '@',
              ),
            ),
            if (_erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: _erro!),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton.icon(
              onPressed: _enviando ? null : _enviar,
              icon: const Icon(Icons.send_rounded),
              label: Text(_enviando ? 'Enviando…' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
