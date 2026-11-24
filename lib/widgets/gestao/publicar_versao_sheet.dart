import 'package:flutter/material.dart';

import '../../models/arquivo_escolhido.dart';
import '../../models/versao_app.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';

class PublicarVersaoSheet extends StatefulWidget {
  const PublicarVersaoSheet({
    super.key,
    required this.instalada,
    required this.onEscolher,
    required this.onPublicar,
  });

  final String instalada;
  final Future<(ArquivoEscolhido?, String?)> Function() onEscolher;
  final Future<String?> Function(
      ArquivoEscolhido arquivo, String versao, String? notas) onPublicar;

  @override
  State<PublicarVersaoSheet> createState() => _PublicarVersaoSheetState();
}

class _PublicarVersaoSheetState extends State<PublicarVersaoSheet> {
  final _versao = TextEditingController();
  final _notas = TextEditingController();
  ArquivoEscolhido? _arquivo;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _versao.dispose();
    _notas.dispose();
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

  Future<void> _publicar() async {
    final arquivo = _arquivo;
    final versao = _versao.text.trim();
    String? invalido;
    if (arquivo == null) {
      invalido = 'Escolha o arquivo do aplicativo (APK).';
    } else if (!RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(versao)) {
      invalido = 'Digite o número da versão, por exemplo 1.0.1.';
    } else if (widget.instalada.isNotEmpty &&
        VersaoApp.comparar(versao, widget.instalada) <= 0) {
      invalido = 'A versão precisa ser maior que ${widget.instalada}.';
    }
    if (invalido != null || arquivo == null) {
      setState(() => _erro = invalido);
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final notas = _notas.text.trim();
    final erro =
        await widget.onPublicar(arquivo, versao, notas.isEmpty ? null : notas);
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
    final arquivo = _arquivo;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Publicar nova versão',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingMd),
            OutlinedButton.icon(
              onPressed: _enviando ? null : _escolher,
              icon: const Icon(Icons.android_rounded),
              label: Text(arquivo == null ? 'Escolher arquivo do app' : arquivo.nome,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _versao,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Número da versão',
                helperText: 'Maior que a instalada (${widget.instalada}).',
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _notas,
              minLines: 2,
              maxLines: 5,
              decoration:
                  const InputDecoration(labelText: 'O que mudou (opcional)'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: _erro!),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton(
              onPressed: _enviando ? null : _publicar,
              child: Text(_enviando ? 'Enviando…' : 'Publicar para todos'),
            ),
          ],
        ),
      ),
    );
  }
}
