import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/profile.dart';
import '../providers/app_info_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/permissoes_provider.dart';
import '../providers/session_provider.dart';
import '../providers/tema_provider.dart';
import '../widgets/common/aparencia_card.dart';
import '../widgets/common/backup_card.dart';
import '../widgets/common/contato_admin_card.dart';
import '../widgets/common/error_banner.dart';
import '../widgets/common/feedback.dart';
import '../widgets/common/permissoes_card.dart';
import '../widgets/common/refreshable_list.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/senha_backup_dialog.dart';
import '../widgets/common/texto_dialog.dart';
import '../widgets/common/versao_card.dart';
import '../widgets/gestao/publicar_versao_sheet.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  Future<String?> _senha(bool criar) => showDialog<String>(
        context: context,
        builder: (_) => SenhaBackupDialog(criar: criar),
      );

  Future<void> _criar() async {
    final perfil = context.read<SessionProvider>().perfil;
    final prov = context.read<BackupProvider>();
    if (perfil == null) return;
    final senha = await _senha(true);
    if (senha == null) return;
    await prov.criar(perfil, senha);
  }

  Future<void> _usar() async {
    final perfil = context.read<SessionProvider>().perfil;
    final prov = context.read<BackupProvider>();
    if (perfil == null) return;
    final bytes = await prov.escolherArquivo();
    if (bytes == null || !mounted) return;
    final senha = await _senha(false);
    if (senha == null) return;
    await prov.restaurar(perfil, bytes, senha);
  }

  Future<void> _abrir(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        mostrarMensagem(context, 'Não foi possível abrir neste aparelho.',
            erro: true);
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, 'Não foi possível abrir: $e', erro: true);
    }
  }

  String _digitos(String t) => t.replaceAll(RegExp(r'\D'), '');

  void _ligar(String t) => _abrir(Uri(scheme: 'tel', path: _digitos(t)));

  void _whatsApp(String t) {
    final d = _digitos(t);
    _abrir(Uri.parse('https://wa.me/${d.length <= 11 ? '55$d' : d}'));
  }

  Future<void> _editarTelefone() async {
    final info = context.read<AppInfoProvider>();
    final t = await showDialog<String>(
      context: context,
      builder: (_) => TextoDialog(
        titulo: 'Número do administrador',
        rotulo: 'Telefone com DDD',
        inicial: info.telefone,
        teclado: TextInputType.phone,
      ),
    );
    if (t == null) return;
    final erro = await info.salvarTelefone(t);
    if (mounted) {
      mostrarMensagem(context, erro ?? 'Número salvo para todos os logins.',
          erro: erro != null);
    }
  }

  Future<void> _publicarVersao() async {
    final info = context.read<AppInfoProvider>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PublicarVersaoSheet(
        instalada: info.instalada,
        onEscolher: info.escolherArquivo,
        onPublicar: info.publicarVersao,
      ),
    );
    if (ok == true && mounted) {
      mostrarMensagem(context, 'Nova versão publicada para todos os logins.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backup = context.watch<BackupProvider>();
    final tema = context.watch<TemaProvider>();
    final info = context.watch<AppInfoProvider>();
    final perm = context.watch<PermissoesProvider>();
    final papel = context.watch<SessionProvider>().perfil?.perfil;
    final admin = papel == Perfil.admin;
    final erroTema = tema.erro;
    final erroInfo = info.erro;
    final url = info.ultima?.arquivoUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: RefreshableList(
          onRefresh: () => Future.wait([info.carregar(), perm.verificar()]),
          children: [
            const SectionHeader(
                titulo: 'Contato do administrador',
                icone: Icons.support_agent_rounded),
            ContatoAdminCard(
              telefone: info.telefone,
              podeEditar: admin,
              onEditar: _editarTelefone,
              onLigar: _ligar,
              onWhatsApp: _whatsApp,
            ),
            const SectionHeader(
                titulo: 'Versão do app', icone: Icons.system_update_rounded),
            VersaoCard(
              instalada: info.instalada,
              ultima: info.ultima,
              temNova: info.temNova,
              podePublicar: admin || papel == Perfil.gestao,
              onPublicar: _publicarVersao,
              onBaixar: url == null ? null : () => _abrir(Uri.parse(url)),
            ),
            if (erroInfo != null)
              ErrorBanner(mensagem: erroInfo, onTentarNovamente: info.carregar),
            const SectionHeader(
                titulo: 'Permissões do celular',
                icone: Icons.verified_user_rounded),
            PermissoesCard(
              internet: perm.internet,
              notificacoes: perm.notificacoes,
              arquivos: perm.arquivos,
              ocupado: perm.ocupado,
              erro: perm.erro,
              onInternet: perm.verificarInternet,
              onNotificacoes: perm.pedirNotificacoes,
              onArquivos: perm.autorizarArquivos,
            ),
            const SectionHeader(
                titulo: 'Cores e letras', icone: Icons.palette_rounded),
            AparenciaCard(
              fonte: tema.fonte,
              cor: tema.cor,
              degrade: tema.degrade,
              transparencia: tema.transparenciaBalao,
              onFonte: tema.definirFonte,
              onCor: tema.definirCor,
              onDegrade: tema.definirDegrade,
              onTransparencia: tema.definirTransparencia,
            ),
            if (erroTema != null) ErrorBanner(mensagem: erroTema),
            const SectionHeader(
                titulo: 'Backup dos seus dados', icone: Icons.backup_rounded),
            BackupCard(
              ocupado: backup.ocupado,
              erro: backup.erro,
              sucesso: backup.sucesso,
              onCriar: _criar,
              onUsar: _usar,
            ),
          ],
        ),
      ),
    );
  }
}
