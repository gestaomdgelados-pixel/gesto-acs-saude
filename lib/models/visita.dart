import 'parse.dart';

enum StatusVisita { agendada, concluida, naoRealizada }

extension StatusVisitaTexto on StatusVisita {
  String get valor => switch (this) {
        StatusVisita.agendada => 'agendada',
        StatusVisita.concluida => 'concluida',
        StatusVisita.naoRealizada => 'nao_realizada',
      };

  String get rotulo => switch (this) {
        StatusVisita.agendada => 'Agendada',
        StatusVisita.concluida => 'Concluída',
        StatusVisita.naoRealizada => 'Não realizada',
      };
}

StatusVisita statusVisitaDe(String? v) => switch (v) {
      'concluida' => StatusVisita.concluida,
      'nao_realizada' => StatusVisita.naoRealizada,
      _ => StatusVisita.agendada,
    };

class Visita {
  const Visita({
    required this.id,
    required this.familiaId,
    required this.agendadaPara,
    required this.motivo,
    required this.status,
    this.justificativa,
    this.concluidaEm,
    this.respostas = const {},
    this.canceladaPeloMorador = false,
  });

  final bool canceladaPeloMorador;

  final String id;
  final String familiaId;
  final DateTime agendadaPara;
  final String motivo;
  final StatusVisita status;
  final String? justificativa;
  final DateTime? concluidaEm;
  final Map<String, String> respostas;

  bool get atrasada {
    final h = DateTime.now();
    return status == StatusVisita.agendada &&
        agendadaPara.isBefore(DateTime(h.year, h.month, h.day));
  }

  factory Visita.fromMap(Map<String, dynamic> m) => Visita(
        id: m['id'] as String,
        familiaId: m['familia_id'] as String,
        agendadaPara: lerData(m['agendada_para']) ?? DateTime.now(),
        motivo: (m['motivo'] ?? '') as String,
        status: statusVisitaDe(m['status'] as String?),
        justificativa: m['justificativa'] as String?,
        concluidaEm: lerData(m['concluida_em']),
        respostas: (m['questionario'] as Map?)
                ?.map((k, v) => MapEntry('$k', '$v')) ??
            const {},
        canceladaPeloMorador: (m['cancelada_pelo_morador'] ?? false) as bool,
      );
}
