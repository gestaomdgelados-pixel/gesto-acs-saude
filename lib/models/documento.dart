import 'estado_envio.dart';
import 'parse.dart';

class Documento {
  const Documento({
    required this.id,
    required this.remetenteId,
    required this.destinatarioId,
    required this.nomeArquivo,
    required this.caminho,
    this.remetenteNome,
    this.destinatarioUsuario,
    this.enviadoEm,
    this.recebidoEm,
    this.vistoEm,
  });

  final String id;
  final String remetenteId;
  final String destinatarioId;
  final String nomeArquivo;
  final String caminho;
  final String? remetenteNome;
  final String? destinatarioUsuario;
  final DateTime? enviadoEm;
  final DateTime? recebidoEm;
  final DateTime? vistoEm;

  EstadoEnvio get estado => estadoEnvio(recebidoEm, vistoEm);

  factory Documento.fromMap(Map<String, dynamic> m) => Documento(
        id: m['id'] as String,
        remetenteId: m['remetente_id'] as String,
        destinatarioId: m['destinatario_id'] as String,
        remetenteNome: m['remetente_nome'] as String?,
        destinatarioUsuario: m['destinatario_usuario'] as String?,
        nomeArquivo: (m['nome_arquivo'] ?? 'documento.pdf') as String,
        caminho: (m['caminho'] ?? '') as String,
        enviadoEm: lerData(m['created_at']),
        recebidoEm: lerData(m['recebido_em']),
        vistoEm: lerData(m['visto_em']),
      );
}
