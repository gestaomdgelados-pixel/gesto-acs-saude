import 'parse.dart';

enum StatusVacina { agendada, concluida }

class VacinaTipo {
  const VacinaTipo({required this.id, required this.nome, this.descricao});

  final String id;
  final String nome;
  final String? descricao;

  factory VacinaTipo.fromMap(Map<String, dynamic> m) => VacinaTipo(
        id: m['id'] as String,
        nome: (m['nome'] ?? '') as String,
        descricao: m['descricao'] as String?,
      );
}

class VacinaRegistro {
  const VacinaRegistro({
    required this.id,
    required this.membroId,
    required this.tipoId,
    required this.status,
    this.dataPrevista,
    this.aplicadaEm,
    this.aplicadoPor,
    this.lote,
  });

  final String id;
  final String membroId;
  final String tipoId;
  final StatusVacina status;
  final DateTime? dataPrevista;
  final DateTime? aplicadaEm;
  final String? aplicadoPor;
  final String? lote;

  factory VacinaRegistro.fromMap(Map<String, dynamic> m) => VacinaRegistro(
        id: m['id'] as String,
        membroId: m['membro_id'] as String,
        tipoId: m['tipo_id'] as String,
        status: m['status'] == 'concluida'
            ? StatusVacina.concluida
            : StatusVacina.agendada,
        dataPrevista: lerData(m['data_prevista']),
        aplicadaEm: lerData(m['aplicada_em']),
        aplicadoPor: m['aplicado_por'] as String?,
        lote: m['lote'] as String?,
      );
}

/// Uma vacina do catálogo vista para uma pessoa (com ou sem registro).
class VacinaItem {
  const VacinaItem(this.tipo, this.registro);

  final VacinaTipo tipo;
  final VacinaRegistro? registro;

  bool get concluida => registro?.status == StatusVacina.concluida;
  bool get agendada => registro?.status == StatusVacina.agendada;
}
