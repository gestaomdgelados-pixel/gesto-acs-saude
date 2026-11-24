import 'parse.dart';

class OpcoesMembro {
  OpcoesMembro._();

  static const hipertensao = 'Hipertensão';
  static const diabetes = 'Diabetes';

  static const sexo = ['Feminino', 'Masculino', 'Outro'];
  static const parentesco = [
    'Responsável',
    'Cônjuge',
    'Filho(a)',
    'Pai ou mãe',
    'Irmão(ã)',
    'Avô ou avó',
    'Neto(a)',
    'Outro parente',
    'Sem parentesco',
  ];
  static const escolaridade = [
    'Sem escolaridade',
    'Fundamental incompleto',
    'Fundamental completo',
    'Médio incompleto',
    'Médio completo',
    'Superior incompleto',
    'Superior completo',
  ];
  static const doencas = [
    hipertensao,
    diabetes,
    'Asma',
    'DPOC',
    'Doença cardíaca',
    'AVC',
    'Doença renal',
    'Câncer',
    'Tuberculose',
    'Hanseníase',
    'Saúde mental',
    'Epilepsia',
    'Deficiência',
    'Acamado',
    'Fumante',
    'Álcool ou drogas',
  ];
}

class Membro {
  const Membro({
    this.id = '',
    required this.familiaId,
    required this.nome,
    this.nascimento,
    this.sexo,
    this.cpf,
    this.cartaoSus,
    this.parentesco,
    this.escolaridade,
    this.ocupacao,
    this.gestante = false,
    this.doencas = const [],
    this.outrasDoencas,
    this.medicamentos,
    this.observacao,
  });

  final String id;
  final String familiaId;
  final String nome;
  final DateTime? nascimento;
  final String? sexo;
  final String? cpf;
  final String? cartaoSus;
  final String? parentesco;
  final String? escolaridade;
  final String? ocupacao;
  final bool gestante;
  final List<String> doencas;
  final String? outrasDoencas;
  final String? medicamentos;
  final String? observacao;

  int? get idade {
    final n = nascimento;
    if (n == null) return null;
    final h = DateTime.now();
    var anos = h.year - n.year;
    if (h.month < n.month || (h.month == n.month && h.day < n.day)) anos--;
    return anos;
  }

  factory Membro.fromMap(Map<String, dynamic> m) => Membro(
        id: m['id'] as String,
        familiaId: m['familia_id'] as String,
        nome: (m['nome'] ?? '') as String,
        nascimento: lerData(m['nascimento']),
        sexo: m['sexo'] as String?,
        cpf: m['cpf'] as String?,
        cartaoSus: m['cartao_sus'] as String?,
        parentesco: m['parentesco'] as String?,
        escolaridade: m['escolaridade'] as String?,
        ocupacao: m['ocupacao'] as String?,
        gestante: (m['gestante'] ?? false) as bool,
        doencas: ((m['doencas'] as List?) ?? const []).map((e) => '$e').toList(),
        outrasDoencas: m['outras_doencas'] as String?,
        medicamentos: m['medicamentos'] as String?,
        observacao: m['observacao'] as String?,
      );

  Map<String, dynamic> toMap() {
    final n = nascimento;
    return {
      'familia_id': familiaId,
      'nome': nome,
      'nascimento': n == null ? null : dataSql(n),
      'sexo': sexo,
      'cpf': cpf,
      'cartao_sus': cartaoSus,
      'parentesco': parentesco,
      'escolaridade': escolaridade,
      'ocupacao': ocupacao,
      'gestante': gestante,
      'doencas': doencas,
      'outras_doencas': outrasDoencas,
      'medicamentos': medicamentos,
      'observacao': observacao,
    };
  }
}
