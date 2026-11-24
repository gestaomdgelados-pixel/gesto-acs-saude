DateTime? lerData(Object? valor) =>
    valor is String ? DateTime.tryParse(valor)?.toLocal() : null;

String dataSql(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String? textoOuNulo(String s) {
  final t = s.trim();
  return t.isEmpty ? null : t;
}
