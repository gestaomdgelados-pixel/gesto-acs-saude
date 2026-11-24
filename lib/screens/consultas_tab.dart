import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/consulta.dart';
import '../providers/consultas_provider.dart';
import '../providers/familias_provider.dart';
import '../providers/session_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/async_section.dart';
import '../widgets/common/consulta_acoes.dart';
import '../widgets/common/consulta_card.dart';
import '../widgets/common/feedback.dart';
import '../widgets/common/motivo_dialog.dart';
import '../widgets/common/nova_consulta_sheet.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/texto_dialog.dart';

export '../models/consulta.dart' show ModoConsultas;

class ConsultasTab extends StatefulWidget {
  const ConsultasTab({super.key, required this.modo});

  final ModoConsultas modo;

  @override
  State<ConsultasTab> createState() => _ConsultasTabState();
}

class _ConsultasTabState extends State<ConsultasTab> {
  StatusConsulta _filtro = StatusConsulta.solicitada;

  void _avisar(String? erro, String ok) {
    if (!mounted) return;
    mostrarMensagem(context, erro ?? ok, erro: erro != null);
  }

  Future<void> _nova() async {
    final prov = context.read<ConsultasProvider>();
    final perfil = context.read<SessionProvider>().perfil;
    if (perfil == null) return;
    final agente = widget.modo == ModoConsultas.agente;
    final pessoas = agente
        ? [
            for (final m in context.read<FamiliasProvider>().membros)
              OpcaoPessoa(m.id, m.nome),
          ]
        : <OpcaoPessoa>[];
    if (agente && pessoas.isEmpty) {
      _avisar('Cadastre pessoas nas famílias antes de solicitar consultas.', '');
      return;
    }
    final agenteId = perfil.agenteId;
    if (!agente && agenteId == null) {
      _avisar(
          'Seu login ainda não tem agente de saúde definido. Peça ao administrador para definir.',
          '');
      return;
    }
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NovaConsultaSheet(
        modoAgente: agente,
        pessoas: pessoas,
        meuId: perfil.id,
        meuNome: perfil.nome,
        agenteId: agenteId,
        agenteNome: agenteId == null ? null : prov.nomeAgente(agenteId),
        onEnviar: prov.criar,
      ),
    );
    if (ok == true) {
      _avisar(null,
          agente ? 'Consulta criada. Agora encaminhe à gestão.' : 'Consulta enviada para sua agente.');
    }
  }

  Future<void> _encaminhar(Consulta c) async {
    final prov = context.read<ConsultasProvider>();
    final usuario = await showDialog<String>(
      context: context,
      builder: (_) => TextoDialog(
        titulo: c.gestorId == null ? 'Encaminhar à gestão' : 'Reencaminhar',
        rotulo: 'Usuário da pessoa da gestão',
        ajuda: 'Só essa pessoa vai receber. Digite o nome de usuário exatamente como foi cadastrado.',
        botao: 'Enviar',
      ),
    );
    if (usuario == null) return;
    _avisar(await prov.encaminhar(c, usuario), 'Consulta enviada para @$usuario.');
  }

  Future<void> _aceitar(Consulta c) async {
    final prov = context.read<ConsultasProvider>();
    final hoje = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDate: hoje,
      helpText: 'Data da consulta',
    );
    if (dia == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Horário da consulta',
    );
    if (hora == null) return;
    final erro = await prov.aceitar(
        c, DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute));
    _avisar(erro, 'Consulta aceita.');
  }

  Future<void> _cancelar(Consulta c) async {
    final prov = context.read<ConsultasProvider>();
    final motivo = await showDialog<String>(
      context: context,
      builder: (_) => const MotivoDialog(titulo: 'Cancelar consulta'),
    );
    if (motivo == null) return;
    _avisar(await prov.cancelar(c, motivo), 'Consulta cancelada.');
  }

  Future<void> _ver(Consulta c) async {
    final erro = await context.read<ConsultasProvider>().marcarVista(c);
    if (erro != null) _avisar(erro, '');
  }

  Widget? _acoes(Consulta c, String? meuId) {
    if (c.status != StatusConsulta.solicitada) return null;
    if (widget.modo == ModoConsultas.usuario && c.solicitanteId != meuId) {
      return null;
    }
    return ConsultaAcoes(
      consulta: c,
      modo: widget.modo,
      souSolicitante: c.solicitanteId == meuId,
      onCancelar: () => _cancelar(c),
      onAceitar: () => _aceitar(c),
      onEncaminhar: () => _encaminhar(c),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConsultasProvider>();
    final meuId = context.watch<SessionProvider>().perfil?.id;
    final gestao = widget.modo == ModoConsultas.gestao;
    final lista = prov.doStatus(_filtro);

    return RefreshableList(
      onRefresh: prov.carregar,
      children: [
        const SectionHeader(
            titulo: 'Consultas', icone: Icons.medical_services_rounded),
        if (!gestao) ...[
          FilledButton.icon(
            onPressed: _nova,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Solicitar nova consulta'),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
        SegmentedButton<StatusConsulta>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
                value: StatusConsulta.solicitada, label: Text('Solicitadas')),
            ButtonSegment(value: StatusConsulta.aceita, label: Text('Aceitas')),
            ButtonSegment(
                value: StatusConsulta.cancelada, label: Text('Canceladas')),
          ],
          selected: {_filtro},
          onSelectionChanged: (s) => setState(() => _filtro = s.first),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        AsyncSection(
          carregando: prov.carregando,
          erro: prov.erro,
          vazio: lista.isEmpty,
          textoVazio: 'Nenhuma consulta aqui.',
          onTentarNovamente: prov.carregar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: ConsultaCard(
                    consulta: c,
                    nomeAgente: prov.nomeAgente(c.agenteId),
                    estado: switch (widget.modo) {
                      ModoConsultas.usuario => c.estadoAgente,
                      ModoConsultas.agente =>
                        c.gestorId != null ? c.estadoGestao : null,
                      ModoConsultas.gestao => null,
                    },
                    estadoPrefixo: widget.modo == ModoConsultas.usuario
                        ? 'Agente'
                        : 'Gestão',
                    onTap: () => _ver(c),
                    acoes: _acoes(c, meuId),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
