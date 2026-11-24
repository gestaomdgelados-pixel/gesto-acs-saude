import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/agente_contato_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/agente/contato_agente_sheet.dart';
import '../../widgets/common/feedback.dart';
import '../../providers/tema_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/refreshable_list.dart';
import '../../widgets/common/resumo_tile.dart';
import '../../widgets/common/saudacao_header.dart';
import '../../widgets/common/section_header.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final tema = context.watch<TemaProvider>();
    final perfil = session.perfil;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final erroTema = tema.erro;

    return RefreshableList(
      onRefresh: () async {},
      children: [
        SaudacaoHeader(nome: perfil?.nome ?? '', perfil: 'Agente de saúde'),
        if (perfil != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: Text('Login: ${perfil.usuario}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        const SectionHeader(titulo: 'Aparência', icone: Icons.palette_rounded),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text('Tema escuro'),
            value: escuro,
            onChanged: (v) =>
                tema.definir(v ? ThemeMode.dark : ThemeMode.light),
          ),
        ),
        if (erroTema != null) ...[
          const SizedBox(height: AppTheme.spacingSm),
          ErrorBanner(mensagem: erroTema),
        ],
        const SectionHeader(titulo: 'Configurações', icone: Icons.settings_rounded),
        ResumoTile(
          icone: Icons.vaccines_rounded,
          titulo: 'Cadastro de vacinas',
          subtitulo: 'Vacinas que valem para todas as pessoas',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/agente/vacinas-config'),
        ),
        ResumoTile(
          icone: Icons.contact_phone_rounded,
          titulo: 'Meu contato para os moradores',
          subtitulo: 'Área, telefone, WhatsApp, dias e horários',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final prov = context.read<AgenteContatoProvider>();
            final ok = await showModalBottomSheet<bool>(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (_) => ContatoAgenteSheet(
                  inicial: prov.contato, onSalvar: prov.salvar),
            );
            if (ok == true && context.mounted) {
              mostrarMensagem(context, 'Contato salvo.');
            }
          },
        ),
        ResumoTile(
          icone: Icons.backup_rounded,
          titulo: 'Configurações',
          subtitulo: 'Contato do admin, versão, permissões, cores e backup',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/agente/configuracoes'),
        ),
        ResumoTile(
          icone: Icons.description_rounded,
          titulo: 'Documentos para a gestão',
          subtitulo: 'Enviar PDF para uma pessoa da gestão',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/agente/documentos'),
        ),
        ResumoTile(
          icone: Icons.assignment_rounded,
          titulo: 'Solicitações à gestão',
          subtitulo: 'Consultas, reclamações e outros pedidos',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/agente/solicitacoes'),
        ),
        ResumoTile(
          icone: Icons.logout_rounded,
          titulo: 'Sair',
          onTap: () => context.read<SessionProvider>().sair(),
        ),
      ],
    );
  }
}
