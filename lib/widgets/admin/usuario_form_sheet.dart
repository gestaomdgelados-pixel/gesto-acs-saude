import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../theme/theme.dart';
import '../common/error_banner.dart';

class UsuarioFormSheet extends StatefulWidget {
  const UsuarioFormSheet({
    super.key,
    required this.agentes,
    required this.onSalvar,
    this.existente,
  });

  final Profile? existente;
  final List<Profile> agentes;
  final Future<String?> Function(LoginDados d) onSalvar;

  @override
  State<UsuarioFormSheet> createState() => _UsuarioFormSheetState();
}

class _UsuarioFormSheetState extends State<UsuarioFormSheet> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.existente?.nome);
  late final _usuario = TextEditingController(text: widget.existente?.usuario);
  final _senha = TextEditingController();
  late Perfil _perfil = widget.existente?.perfil ?? Perfil.usuario;
  late String? _agenteId = widget.existente?.agenteId;
  late bool _ativo = widget.existente?.ativo ?? true;
  bool _salvando = false;
  String? _erro;

  bool get _novo => widget.existente == null;

  @override
  void dispose() {
    _nome.dispose();
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await widget.onSalvar(LoginDados(
      nome: _nome.text.trim(),
      usuario: _usuario.text.trim().toLowerCase(),
      senha: _novo ? _senha.text : null,
      perfil: _perfil,
      agenteId: _perfil == Perfil.usuario ? _agenteId : null,
      ativo: _ativo,
    ));
    if (!mounted) return;
    if (erro == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final agenteValido = widget.agentes.any((a) => a.id == _agenteId);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd,
          AppTheme.spacingMd + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_novo ? 'Novo login' : 'Editar login',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _usuario,
                enabled: _novo,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Usuário (para entrar)', prefixText: '@'),
                validator: (v) => RegExp(r'^[a-z0-9._-]{3,30}$')
                        .hasMatch((v ?? '').trim().toLowerCase())
                    ? null
                    : 'De 3 a 30 letras minúsculas, números, ponto ou traço',
              ),
              if (_novo) ...[
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  controller: _senha,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Senha inicial',
                      helperText: 'A pessoa troca no primeiro acesso'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              DropdownButtonFormField<Perfil>(
                initialValue: _perfil,
                decoration: const InputDecoration(labelText: 'Perfil'),
                items: [
                  for (final p in Perfil.values)
                    DropdownMenuItem(value: p, child: Text(p.rotulo)),
                ],
                onChanged: (p) => setState(() => _perfil = p ?? _perfil),
              ),
              if (_perfil == Perfil.usuario && widget.agentes.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMd),
                DropdownButtonFormField<String?>(
                  initialValue: agenteValido ? _agenteId : null,
                  decoration:
                      const InputDecoration(labelText: 'Agente responsável'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Nenhum')),
                    for (final a in widget.agentes)
                      DropdownMenuItem<String?>(value: a.id, child: Text(a.nome)),
                  ],
                  onChanged: (v) => setState(() => _agenteId = v),
                ),
              ],
              if (!_novo)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Login ativo'),
                  subtitle: const Text('Desativado não consegue entrar'),
                  value: _ativo,
                  onChanged: (v) => setState(() => _ativo = v),
                ),
              if (_erro != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                ErrorBanner(mensagem: _erro!),
              ],
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: Text(_salvando
                    ? 'Salvando…'
                    : (_novo ? 'Criar login ativo' : 'Salvar alterações')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
