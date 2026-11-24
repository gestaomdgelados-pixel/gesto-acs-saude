import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/familia.dart';
import '../../models/parse.dart';
import '../../providers/familias_provider.dart';
import '../../widgets/common/campo_opcoes.dart';
import '../../widgets/common/campo_texto.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/formulario_pagina.dart';

class FamiliaFormScreen extends StatefulWidget {
  const FamiliaFormScreen({super.key, this.familiaId});

  final String? familiaId;

  @override
  State<FamiliaFormScreen> createState() => _FamiliaFormScreenState();
}

class _FamiliaFormScreenState extends State<FamiliaFormScreen> {
  static const _chaves = [
    'responsavel',
    'telefone',
    'logradouro',
    'numero',
    'bairro',
    'complemento',
    'microarea',
    'observacao',
  ];

  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c = {
    for (final k in _chaves) k: TextEditingController(),
  };
  String? _moradia;
  String? _agua;
  String? _esgoto;
  String? _lixo;
  String? _renda;
  bool _energia = true;
  bool _animais = false;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final id = widget.familiaId;
    final f = id == null ? null : context.read<FamiliasProvider>().familiaPorId(id);
    if (f == null) return;
    _c['responsavel']!.text = f.responsavel;
    _c['telefone']!.text = f.telefone ?? '';
    _c['logradouro']!.text = f.logradouro;
    _c['numero']!.text = f.numero ?? '';
    _c['bairro']!.text = f.bairro ?? '';
    _c['complemento']!.text = f.complemento ?? '';
    _c['microarea']!.text = f.microarea ?? '';
    _c['observacao']!.text = f.observacao ?? '';
    _moradia = f.moradia;
    _agua = f.agua;
    _esgoto = f.esgoto;
    _lixo = f.lixo;
    _renda = f.renda;
    _energia = f.energia;
    _animais = f.animais;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _n(String chave) => textoOuNulo(_c[chave]!.text);

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await context.read<FamiliasProvider>().salvarFamilia(Familia(
          id: widget.familiaId ?? '',
          responsavel: _c['responsavel']!.text.trim(),
          logradouro: _c['logradouro']!.text.trim(),
          telefone: _n('telefone'),
          numero: _n('numero'),
          bairro: _n('bairro'),
          complemento: _n('complemento'),
          microarea: _n('microarea'),
          moradia: _moradia,
          agua: _agua,
          esgoto: _esgoto,
          lixo: _lixo,
          energia: _energia,
          animais: _animais,
          renda: _renda,
          observacao: _n('observacao'),
        ));
    if (!mounted) return;
    if (erro == null) {
      mostrarMensagem(context, 'Família salva.');
      context.pop();
    } else {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormularioPagina(
      titulo: widget.familiaId == null ? 'Nova família' : 'Editar família',
      formKey: _form,
      salvando: _salvando,
      erro: _erro,
      onSalvar: _salvar,
      children: [
        CampoTexto(
            controller: _c['responsavel']!,
            rotulo: 'Nome do responsável',
            obrigatorio: true),
        CampoTexto(
            controller: _c['telefone']!,
            rotulo: 'Telefone',
            teclado: TextInputType.phone),
        CampoTexto(
            controller: _c['logradouro']!,
            rotulo: 'Rua ou logradouro',
            obrigatorio: true),
        CampoTexto(controller: _c['numero']!, rotulo: 'Número'),
        CampoTexto(controller: _c['bairro']!, rotulo: 'Bairro'),
        CampoTexto(controller: _c['complemento']!, rotulo: 'Complemento'),
        CampoTexto(controller: _c['microarea']!, rotulo: 'Microárea'),
        CampoOpcoes(
            rotulo: 'Tipo de moradia',
            opcoes: OpcoesFamilia.moradia,
            valor: _moradia,
            onChanged: (v) => setState(() => _moradia = v)),
        CampoOpcoes(
            rotulo: 'Abastecimento de água',
            opcoes: OpcoesFamilia.agua,
            valor: _agua,
            onChanged: (v) => setState(() => _agua = v)),
        CampoOpcoes(
            rotulo: 'Esgotamento sanitário',
            opcoes: OpcoesFamilia.esgoto,
            valor: _esgoto,
            onChanged: (v) => setState(() => _esgoto = v)),
        CampoOpcoes(
            rotulo: 'Destino do lixo',
            opcoes: OpcoesFamilia.lixo,
            valor: _lixo,
            onChanged: (v) => setState(() => _lixo = v)),
        CampoOpcoes(
            rotulo: 'Renda familiar',
            opcoes: OpcoesFamilia.renda,
            valor: _renda,
            onChanged: (v) => setState(() => _renda = v)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tem energia elétrica'),
          value: _energia,
          onChanged: (v) => setState(() => _energia = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tem animais em casa'),
          value: _animais,
          onChanged: (v) => setState(() => _animais = v),
        ),
        CampoTexto(
            controller: _c['observacao']!, rotulo: 'Observações', linhas: 3),
      ],
    );
  }
}
