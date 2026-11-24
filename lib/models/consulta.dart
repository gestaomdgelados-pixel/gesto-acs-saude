import 'estado_envio.dart';
import 'parse.dart';

enum StatusConsulta { solicitada, aceita, cancelada }

/// Quem está olhando a lista de consultas.
enum ModoConsultas { usuario, agente, gestao }

class OpcaoPessoa {
  const OpcaoPessoa(this.id, this.nome);
  final String id;
  final String nome;
}

class ConsultaRascunho {
  const ConsultaRascunho({
    required this.agenteId,
    required this.paciente,
    required this.especialidade,
    this.membroId,
    this.observacao,
  });

  final String agenteId;
  final String paciente;
  final String especialidade;
  final String? membroId;
  final String? observacao;
}

class Consulta {
  const Consulta({
    required this.id,
    required this.solicitanteId,
    required this.agenteId,
    required this.paciente,
    required this.especialidade,
    required this.status,
    this.membroId,
    this.observacao,
    this.dataMarcada,
    this.motivo,
    this.criadoEm,
    this.gestorId,
    this.gestorUsuario,
    this.encaminhadaEm,
    this.agenteRecebidoEm,
    this.agenteVistoEm,
    this.gestorRecebidoEm,
    this.gestorVistoEm,
  });

  static const especialidades = [
    'Médico clínico geral',
    'Dentista',
    'Pediatra',
    'Ginecologista',
    'Cardiologista',
    'Oftalmologista',
    'Dermatologista',
    'Psicólogo',
    'Nutricionista',
    'Fisioterapeuta',
    'Outra especialidade',
  ];

  final String id;
  final String solicitanteId;
  final String agenteId;
  final String? membroId;
  final String paciente;
  final String especialidade;
  final String? observacao;
  final StatusConsulta status;
  final DateTime? dataMarcada;
  final String? motivo;
  final DateTime? criadoEm;
  final String? gestorId;
  final String? gestorUsuario;
  final DateTime? encaminhadaEm;
  final DateTime? agenteRecebidoEm;
  final DateTime? agenteVistoEm;
  final DateTime? gestorRecebidoEm;
  final DateTime? gestorVistoEm;

  bool get aguardandoEncaminhar =>
      status == StatusConsulta.solicitada && gestorId == null;
  EstadoEnvio get estadoAgente => estadoEnvio(agenteRecebidoEm, agenteVistoEm);
  EstadoEnvio get estadoGestao => estadoEnvio(gestorRecebidoEm, gestorVistoEm);

  factory Consulta.fromMap(Map<String, dynamic> m) => Consulta(
        id: m['id'] as String,
        solicitanteId: m['solicitante_id'] as String,
        agenteId: m['agente_id'] as String,
        membroId: m['membro_id'] as String?,
        paciente: (m['paciente'] ?? '') as String,
        especialidade: (m['especialidade'] ?? '') as String,
        observacao: m['observacao'] as String?,
        status: switch (m['status']) {
          'aceita' => StatusConsulta.aceita,
          'cancelada' => StatusConsulta.cancelada,
          _ => StatusConsulta.solicitada,
        },
        dataMarcada: lerData(m['data_marcada']),
        motivo: m['motivo'] as String?,
        criadoEm: lerData(m['created_at']),
        gestorId: m['gestor_id'] as String?,
        gestorUsuario: m['gestor_usuario'] as String?,
        encaminhadaEm: lerData(m['encaminhada_em']),
        agenteRecebidoEm: lerData(m['agente_recebido_em']),
        agenteVistoEm: lerData(m['agente_visto_em']),
        gestorRecebidoEm: lerData(m['gestor_recebido_em']),
        gestorVistoEm: lerData(m['gestor_visto_em']),
      );
}
