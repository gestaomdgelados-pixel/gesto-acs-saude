import 'package:flutter/material.dart';

import '../../models/consulta.dart';
import '../../theme/theme.dart';
import 'error_banner.dart';

class NovaConsultaSheet extends StatefulWidget {
  const NovaConsultaSheet({
    super.key,
    required this.modoAgente,
    required this.pessoas,
    required this.meuId,
    required this.meuNome,
    required this.onEnviar,
    this.agenteId,
    this.agenteNome,
  });

  /// No modo agente, escolhe uma das [pessoas] cadastradas; no modo usuário
  /// a agente responsável ([agenteId]) já vem definida pelo admin.
  final bool modoAgente;
  final List<OpcaoPessoa> pessoas;
  final String meuId;
  final String meuNome;
  final String? agenteId;
  final String? agenteNome;
  final Future<String?> Function(ConsultaRascunho r) onEnviar;

  @override
  State<NovaConsultaSheet> createState() => _NovaConsultaSheetState();
}

class _NovaConsultaSheetState extends State<NovaConsultaSheet> {
  final _obs = TextEditingController();
  String? _especialidade;
  String? _pessoa;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  String? _validar() {
    if (_especialidade == null) return 'Escolha o tipo de consulta.';
    if (widget.modoAgente && _pessoa == null) {
      return 'Escolha a pessoa cadastrada.';
    }
    if (!widget.modoAgente && widget.agenteId == null) {
      return 'Seu login ainda não tem agente de saúde definido. '
          'Peça ao administrador para definir.';
    }
    return null;
  }

  Future<void> _enviar() async {
    final invalido = _validar();
    if (invalido != null) {
      setState(() => _erro = invalido);
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final obs = _obs.text.trim().isEmpty ? null : _obs.text.trim();
    final r = widget.modoAgente
        ? ConsultaRascunho(
            agenteId: widget.meuId,
            membroId: _pessoa,
            paciente: widget.pessoas.firstWhere((o) => o.id == _pessoa).nome,
            especialidade: _especialidade!,
            observacao: obs,
          )
        : ConsultaRascunho(
            agenteId: widget.agenteId!,
            paciente: widget.meuNome,
            especialidade: _especialidade!,
            observacao: obs,
          );
    final erro = await widget.onEnviar(r);
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nova consulta', style: text.titleLarge),
            const SizedBox(height: AppTheme.spacingMd),
            Text('1. Tipo de consulta', style: text.titleSmall),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: [
                for (final e in Consulta.especialidades)
                  ChoiceChip(
                    label: Text(e),
                    selected: _especialidade == e,
                    onSelected: (_) => setState(() => _especialidade = e),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
                widget.modoAgente
                    ? '2. Pessoa cadastrada'
                    : '2. Sua agente de saúde',
                style: text.titleSmall),
            const SizedBox(height: AppTheme.spacingSm),
            if (widget.modoAgente)
              DropdownButtonFormField<String>(
                initialValue: _pessoa,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Pessoa'),
                items: [
                  for (final o in widget.pessoas)
                    DropdownMenuItem(
                      value: o.id,
                      child: Text(o.nome,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _pessoa = v),
              )
            else
              Card(
                child: ListTile(
                  leading: Icon(Icons.health_and_safety_rounded,
                      color: colors.primary),
                  title: Text(widget.agenteNome ?? 'Agente de saúde',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: const Text(
                      'Definida pelo administrador. Ela vai encaminhar seu pedido à gestão.'),
                ),
              ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _obs,
              minLines: 2,
              maxLines: 5,
              decoration:
                  const InputDecoration(labelText: 'Detalhes (opcional)'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              ErrorBanner(mensagem: _erro!),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: Text(_enviando ? 'Enviando…' : 'Solicitar consulta'),
            ),
          ],
        ),
      ),
    );
  }
}
