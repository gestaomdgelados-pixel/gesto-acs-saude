class AgenteContato {
  const AgenteContato({
    this.nome = '',
    this.area,
    this.telefone,
    this.whatsapp,
    this.dias,
    this.horarios,
  });

  final String nome;
  final String? area;
  final String? telefone;
  final String? whatsapp;
  final String? dias;
  final String? horarios;

  static String? _t(Object? v) {
    final s = (v as String?)?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  factory AgenteContato.fromMap(Map<String, dynamic> m) => AgenteContato(
        nome: (m['nome'] ?? '') as String,
        area: _t(m['area']),
        telefone: _t(m['telefone']),
        whatsapp: _t(m['whatsapp']),
        dias: _t(m['dias']),
        horarios: _t(m['horarios']),
      );

  Map<String, dynamic> toMap() => {
        'area': area,
        'telefone': telefone,
        'whatsapp': whatsapp,
        'dias': dias,
        'horarios': horarios,
      };
}
