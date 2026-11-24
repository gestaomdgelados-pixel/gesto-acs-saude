class OpcoesFamilia {
  OpcoesFamilia._();

  static const moradia = [
    'Casa de alvenaria',
    'Casa de madeira',
    'Casa de taipa',
    'Apartamento',
    'Moradia improvisada',
  ];
  static const agua = [
    'Rede pública',
    'Poço ou nascente',
    'Carro-pipa',
    'Outra forma',
  ];
  static const esgoto = [
    'Rede de esgoto',
    'Fossa séptica',
    'Fossa rudimentar',
    'Céu aberto',
  ];
  static const lixo = [
    'Coleta pública',
    'Queimado ou enterrado',
    'Céu aberto',
  ];
  static const renda = [
    'Sem renda',
    'Até 1 salário mínimo',
    '1 a 2 salários mínimos',
    '2 a 3 salários mínimos',
    'Acima de 3 salários mínimos',
  ];
}

class Familia {
  const Familia({
    this.id = '',
    required this.responsavel,
    required this.logradouro,
    this.telefone,
    this.numero,
    this.bairro,
    this.complemento,
    this.microarea,
    this.moradia,
    this.agua,
    this.esgoto,
    this.lixo,
    this.energia = true,
    this.animais = false,
    this.renda,
    this.observacao,
  });

  final String id;
  final String responsavel;
  final String logradouro;
  final String? telefone;
  final String? numero;
  final String? bairro;
  final String? complemento;
  final String? microarea;
  final String? moradia;
  final String? agua;
  final String? esgoto;
  final String? lixo;
  final bool energia;
  final bool animais;
  final String? renda;
  final String? observacao;

  String get endereco {
    final rua = numero == null ? logradouro : '$logradouro, $numero';
    return bairro == null ? rua : '$rua - $bairro';
  }

  factory Familia.fromMap(Map<String, dynamic> m) => Familia(
        id: m['id'] as String,
        responsavel: (m['responsavel'] ?? '') as String,
        logradouro: (m['logradouro'] ?? '') as String,
        telefone: m['telefone'] as String?,
        numero: m['numero'] as String?,
        bairro: m['bairro'] as String?,
        complemento: m['complemento'] as String?,
        microarea: m['microarea'] as String?,
        moradia: m['moradia'] as String?,
        agua: m['agua'] as String?,
        esgoto: m['esgoto'] as String?,
        lixo: m['lixo'] as String?,
        energia: (m['energia'] ?? true) as bool,
        animais: (m['animais'] ?? false) as bool,
        renda: m['renda'] as String?,
        observacao: m['observacao'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'responsavel': responsavel,
        'logradouro': logradouro,
        'telefone': telefone,
        'numero': numero,
        'bairro': bairro,
        'complemento': complemento,
        'microarea': microarea,
        'moradia': moradia,
        'agua': agua,
        'esgoto': esgoto,
        'lixo': lixo,
        'energia': energia,
        'animais': animais,
        'renda': renda,
        'observacao': observacao,
      };
}
