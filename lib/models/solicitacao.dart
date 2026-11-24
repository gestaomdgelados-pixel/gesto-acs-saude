import 'parse.dart';

enum StatusSolicitacao { pendente, agendada, recusada, outro }

class Solicitacao {
  const Solicitacao({
    required this.id,
    required this.especialidade,
    required this.statusBruto,
    this.agenteId,
    this.dataDesejada,
    this.observacao,
    this.dataAgendada,
    this.motivoRecusa,
    this.criadoEm,
  });

  static const separador = ' · ';

  final String id;
  final String especialidade;
  final String statusBruto;
  final String? agenteId;
  final DateTime? dataDesejada;
  final String? observacao;
  final DateTime? dataAgendada;
  final String? motivoRecusa;
  final DateTime? criadoEm;

  /// O tipo (Consulta, Reclamação, Outro) fica no início de `especialidade`.
  String get tipo => especialidade.contains(separador)
      ? especialidade.split(separador).first
      : 'Consulta';

  String get assunto {
    final i = especialidade.indexOf(separador);
    return i < 0 ? especialidade : especialidade.substring(i + separador.length);
  }

  bool get isConsulta => tipo == 'Consulta';

  StatusSolicitacao get status => switch (statusBruto) {
        'pendente' || 'encaminhada' => StatusSolicitacao.pendente,
        'agendada' || 'aceita' => StatusSolicitacao.agendada,
        'recusada' => StatusSolicitacao.recusada,
        _ => StatusSolicitacao.outro,
      };

  factory Solicitacao.fromMap(Map<String, dynamic> m) => Solicitacao(
        id: m['id'] as String,
        especialidade: (m['especialidade'] ?? '') as String,
        statusBruto: (m['status'] ?? 'pendente') as String,
        agenteId: m['agente_id'] as String?,
        dataDesejada: lerData(m['data_desejada']),
        observacao: m['observacao'] as String?,
        dataAgendada: lerData(m['data_agendada']),
        motivoRecusa: m['motivo_recusa'] as String?,
        criadoEm: lerData(m['created_at']),
      );
}

class SolicitacaoRascunho {
  const SolicitacaoRascunho({
    required this.tipo,
    required this.assunto,
    this.dataDesejada,
    this.observacao,
  });

  final String tipo;
  final String assunto;
  final DateTime? dataDesejada;
  final String? observacao;
}
