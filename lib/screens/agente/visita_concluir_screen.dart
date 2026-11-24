import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/questionario_visita.dart';
import '../../providers/familias_provider.dart';
import '../../providers/visitas_provider.dart';
import '../../widgets/agente/pergunta_campo.dart';
import '../../widgets/common/feedback.dart';
import '../../widgets/common/formatos.dart';
import '../../widgets/common/formulario_pagina.dart';
import '../../widgets/common/resumo_tile.dart';

class VisitaConcluirScreen extends StatefulWidget {
  const VisitaConcluirScreen({super.key, required this.visitaId});

  final String visitaId;

  @override
  State<VisitaConcluirScreen> createState() => _VisitaConcluirScreenState();
}

class _VisitaConcluirScreenState extends State<VisitaConcluirScreen> {
  final _form = GlobalKey<FormState>();
  final Map<String, String> _respostas = {};
  bool _salvando = false;
  String? _erro;

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final limpas = Map<String, String>.of(_respostas)
      ..removeWhere((_, v) => v.trim().isEmpty);
    final erro = await context
        .read<VisitasProvider>()
        .concluir(widget.visitaId, limpas);
    if (!mounted) return;
    if (erro == null) {
      mostrarMensagem(context, 'Visita concluída.');
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
    final vis = context.watch<VisitasProvider>();
    final fam = context.watch<FamiliasProvider>();
    final v = vis.visitaPorId(widget.visitaId);
    if (v == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Text(vis.carregando ? 'Carregando…' : 'Visita não encontrada.')),
      );
    }

    return FormularioPagina(
      titulo: 'Concluir visita',
      formKey: _form,
      salvando: _salvando,
      erro: _erro,
      rotuloSalvar: 'Concluir visita',
      onSalvar: _salvar,
      children: [
        ResumoTile(
          icone: Icons.home_work_rounded,
          titulo: fam.nomeDaFamilia(v.familiaId),
          subtitulo: '${dataExtensa(v.agendadaPara)} · ${v.motivo}',
        ),
        for (final p in QuestionarioVisita.perguntas)
          PerguntaCampo(
            pergunta: p,
            onChanged: (valor) => _respostas[p.id] = valor,
          ),
      ],
    );
  }
}
