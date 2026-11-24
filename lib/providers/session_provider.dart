import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../repositories/app_exception.dart';
import '../repositories/auth_repository.dart';
import '../repositories/prefs_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

enum SessaoStatus { carregando, deslogado, logado }

class SessionProvider extends SafeNotifier {
  SessionProvider(this._auth, this._prefs);

  final AuthRepository _auth;
  final PrefsRepository _prefs;
  StreamSubscription<AuthState>? _sub;

  SessaoStatus status = SessaoStatus.carregando;
  Profile? perfil;
  bool ocupado = false;
  String? erro;
  String ultimoUsuario = '';

  String get rotaInicial => switch (perfil?.perfil) {
        Perfil.admin => '/admin',
        Perfil.gestao => '/gestao',
        Perfil.agente => '/agente',
        _ => '/usuario',
      };

  Future<void> iniciar() async {
    _sub = _auth.mudancas.listen(
      (estado) {
        if (estado.event == AuthChangeEvent.signedOut &&
            status != SessaoStatus.deslogado) {
          perfil = null;
          status = SessaoStatus.deslogado;
          notifyListeners();
        }
      },
      onError: (Object e) {
        erro = mensagemDeErro(e);
        notifyListeners();
      },
    );
    try {
      ultimoUsuario = await _prefs.ultimoUsuario();
      final user = _auth.usuarioAtual;
      if (user == null) {
        status = SessaoStatus.deslogado;
      } else {
        await _carregarPerfil(user.id);
      }
    } catch (e) {
      erro = mensagemDeErro(e);
      perfil = null;
      status = SessaoStatus.deslogado;
    }
    notifyListeners();
  }

  Future<void> _carregarPerfil(String id) async {
    final p = await _auth.perfil(id);
    if (p == null) {
      await _auth.sair();
      throw const AppException(
          'Este login não tem perfil cadastrado. Fale com o administrador.');
    }
    if (!p.ativo) {
      await _auth.sair();
      throw const AppException(
          'Este login está desativado. Fale com o administrador.');
    }
    perfil = p;
    status = SessaoStatus.logado;
  }

  Future<void> entrar(String usuario, String senha) async {
    ocupado = true;
    erro = null;
    notifyListeners();
    try {
      await _auth.entrar(usuario, senha);
      final id = _auth.usuarioAtual?.id;
      if (id == null) throw const AppException('Não foi possível entrar.');
      await _carregarPerfil(id);
      ultimoUsuario = usuario.trim();
      await _prefs.salvarUltimoUsuario(ultimoUsuario);
    } catch (e) {
      perfil = null;
      status = SessaoStatus.deslogado;
      erro = mensagemDeErro(e);
    } finally {
      ocupado = false;
      notifyListeners();
    }
  }

  Future<String?> trocarSenha(String nova) async {
    try {
      await _auth.trocarSenha(nova);
      notifyListeners();
      return null;
    } catch (e) {
      return mensagemDeErro(e);
    }
  }

  Future<void> sair() async {
    try {
      await _auth.sair();
    } catch (e) {
      erro = mensagemDeErro(e);
    }
    perfil = null;
    status = SessaoStatus.deslogado;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
