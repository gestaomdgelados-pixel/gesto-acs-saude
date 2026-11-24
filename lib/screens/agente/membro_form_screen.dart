import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/membro.dart';
import '../../models/parse.dart';
import '../../providers/familias_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/agente/doencas_selector.dart';
import '../../widgets/common/campo_data.dart';
import '../../widgets/common/campo_opcoes.dart';
import '../../widgets/common/campo_texto.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/formulario_pagina.dart';

class MembroFormScreen extends StatefulWidget {
  const MembroFormScreen({super.key, required this.familiaId, this.membroId});

  final String familiaId;
  final String? membroId;

  @override
  State<MembroFormScreen> createState() => _MembroFormScreenState();
}

class _MembroFormScreenState extends State<MembroFormScreen> {
  static const _chaves = [
    'nome',
    'cpf',
    'cartao',
    'ocupacao',
    'outras',
    'medicamentos',
    'observacao',
  ];

  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c = {
    for (final k in _chaves) k: TextEditingController(),
  };
  DateTime? _nascimento;
  String? _sexo;
  String? _parentesco;
  String? _escolaridade;
  bool _gestante = false;
  List<String> _doencas = [];
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final id = widget.membroId;
    final m = id == null ? null : context.read<FamiliasProvider>().membroPorId(id);
    if (m == null) return;
    _c['nome']!.text = m.nome;
    _c['cpf']!.text = m.cpf ?? '';
    _c['cartao']!.text = m.cartaoSus ?? '';
    _c['ocupacao']!.text = m.ocupacao ?? '';
    _c['outras']!.text = m.outrasDoencas ?? '';
    _c['medicamentos']!.text = m.medicamentos ?? '';
    _c['observacao']!.text = m.observacao ?? '';
    _nascimento = m.nascimento;
    _sexo = m.sexo;
    _parentesco = m.parentesco;
    _escolaridade = m.escolaridade;
    _gestante = m.gestante;
    _doencas = [...m.doencas];
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
    final erro = await context.read<FamiliasProvider>().salvarMembro(Membro(
          id: widget.membroId ?? '',
          familiaId: widget.familiaId,
          nome: _c['nome']!.text.trim(),
          nascimento: _nascimento,
          sexo: _sexo,
          cpf: _n('cpf'),
          cartaoSus: _n('cartao'),
          parentesco: _parentesco,
          escolaridade: _escolaridade,
          ocupacao: _n('ocupacao'),
          gestante: _gestante,
          doencas: _doencas,
          outrasDoencas: _n('outras'),
          medicamentos: _n('medicamentos'),
          observacao: _n('observacao'),
        ));
    if (!mounted) return;
    if (erro == null) {
      mostrarMensagem(context, 'Pessoa salva.');
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
      titulo: widget.membroId == null ? 'Nova pessoa' : 'Editar pessoa',
      formKey: _form,
      salvando: _salvando,
      erro: _erro,
      onSalvar: _salvar,
      children: [
        CampoTexto(
            controller: _c['nome']!, rotulo: 'Nome completo', obrigatorio: true),
        CampoData(
          rotulo: 'Data de nascimento',
          valor: _nascimento,
          primeira: DateTime(1900),
          ultima: DateTime.now(),
          onChanged: (d) => setState(() => _nascimento = d),
        ),
        CampoOpcoes(
          rotulo: 'Sexo',
          opcoes: OpcoesMembro.sexo,
          valor: _sexo,
          onChanged: (v) => setState(() {
            _sexo = v;
            if (v != 'Feminino') _gestante = false;
          }),
        ),
        CampoOpcoes(
            rotulo: 'Parentesco com o responsável',
            opcoes: OpcoesMembro.parentesco,
            valor: _parentesco,
            onChanged: (v) => setState(() => _parentesco = v)),
        CampoTexto(
            controller: _c['cpf']!, rotulo: 'CPF', teclado: TextInputType.number),
        CampoTexto(
            controller: _c['cartao']!,
            rotulo: 'Cartão do SUS',
            teclado: TextInputType.number),
        CampoOpcoes(
            rotulo: 'Escolaridade',
            opcoes: OpcoesMembro.escolaridade,
            valor: _escolaridade,
            onChanged: (v) => setState(() => _escolaridade = v)),
        CampoTexto(controller: _c['ocupacao']!, rotulo: 'Ocupação'),
        if (_sexo == 'Feminino')
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Gestante'),
            value: _gestante,
            onChanged: (v) => setState(() => _gestante = v),
          ),
        const SizedBox(height: AppTheme.spacingSm),
        Text('Doenças e condições', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppTheme.spacingSm),
        DoencasSelector(
          opcoes: OpcoesMembro.doencas,
          selecionadas: _doencas,
          onChanged: (lista) => setState(() => _doencas = lista),
        ),
        CampoTexto(controller: _c['outras']!, rotulo: 'Outras doenças'),
        CampoTexto(
            controller: _c['medicamentos']!,
            rotulo: 'Medicamentos de uso contínuo',
            linhas: 2),
        CampoTexto(
            controller: _c['observacao']!, rotulo: 'Observações', linhas: 3),
      ],
    );
  }
}
