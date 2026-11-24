import 'parse.dart';

/// Linha da tabela `reunioes`: tipo 'reuniao' ou 'aviso'.
class Aviso {
  const Aviso({
    required this.id,
    required this.titulo,
    required this.data,
    required this.tipo,
    this.descricao,
  });

  final String id;
  final String titulo;
  final DateTime data;
  final String tipo;
  final String? descricao;

  bool get isReuniao => tipo == 'reuniao';

  factory Aviso.fromMap(Map<String, dynamic> m) => Aviso(
        id: m['id'] as String,
        titulo: (m['titulo'] ?? '') as String,
        data: lerData(m['data']) ?? DateTime.now(),
        tipo: (m['tipo'] ?? 'reuniao') as String,
        descricao: m['descricao'] as String?,
      );
}

/// Formulário da gestão: 'reuniao' e 'aviso' vão para os agentes,
/// 'campanha' vira um aviso para todos os logins.
class AvisoRascunho {
  const AvisoRascunho({
    required this.tipo,
    required this.titulo,
    required this.data,
    this.descricao,
    this.cor,
  });

  final String tipo;
  final String titulo;
  final DateTime data;
  final String? descricao;
  final String? cor;
}
