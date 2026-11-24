import 'parse.dart';

enum Perfil { usuario, agente, gestao, admin }

Perfil perfilDe(String? valor) => Perfil.values
    .firstWhere((p) => p.name == valor, orElse: () => Perfil.usuario);

extension PerfilRotulo on Perfil {
  String get rotulo => switch (this) {
        Perfil.usuario => 'Usuário comum',
        Perfil.agente => 'Agente de saúde',
        Perfil.gestao => 'Gestão',
        Perfil.admin => 'Administrador',
      };
}

class Profile {
  const Profile({
    required this.id,
    required this.nome,
    required this.usuario,
    required this.perfil,
    required this.ativo,
    this.agenteId,
    this.criadoEm,
  });

  final String id;
  final String nome;
  final String usuario;
  final Perfil perfil;
  final bool ativo;
  final String? agenteId;
  final DateTime? criadoEm;

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        nome: (m['nome'] ?? '') as String,
        usuario: (m['usuario'] ?? '') as String,
        perfil: perfilDe(m['role'] as String?),
        ativo: (m['ativo'] ?? true) as bool,
        agenteId: m['agente_id'] as String?,
        criadoEm: lerData(m['created_at']),
      );
}

/// Dados preenchidos pelo admin ao criar ou editar um login.
class LoginDados {
  const LoginDados({
    required this.nome,
    required this.usuario,
    required this.perfil,
    this.senha,
    this.agenteId,
    this.ativo = true,
  });

  final String nome;
  final String usuario;
  final Perfil perfil;
  final String? senha;
  final String? agenteId;
  final bool ativo;
}
