import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/app_exception.dart';

String mensagemDeErro(Object e) {
  if (e is AppException) return e.message;
  if (e is AuthException) {
    if (e.statusCode == '429') {
      return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
    }
    if (e.message.contains('Invalid login credentials')) {
      return 'Usuário ou senha incorretos.';
    }
    if (e.message.toLowerCase().contains('banned')) {
      return 'Este login está desativado. Fale com o administrador.';
    }
    return e.message;
  }
  if (e is PostgrestException) {
    return 'Erro no servidor: ${e.message}${e.code != null ? ' (${e.code})' : ''}';
  }
  if (e is StorageException) return 'Erro ao enviar arquivo: ${e.message}';
  if (e is FunctionException) {
    final d = e.details;
    if (d is Map && d['error'] != null) return '${d['error']}';
    if (e.status == 404) {
      return 'A função "bright-function" ainda não foi publicada no Supabase.';
    }
    return 'Erro na função do servidor (${e.status}).';
  }
  return e.toString();
}
