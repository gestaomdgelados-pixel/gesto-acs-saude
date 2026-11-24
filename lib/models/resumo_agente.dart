import 'familia.dart';
import 'membro.dart';
import 'vacina.dart';
import 'visita.dart';

class ResumoAgente {
  const ResumoAgente({
    required this.familias,
    required this.membros,
    required this.gestantes,
    required this.hipertensos,
    required this.diabeticos,
    required this.vacinasPendentes,
    required this.vacinasAgendadas,
    required this.vacinasConcluidas,
    required this.visitasHoje,
    required this.visitasAgendadas,
    required this.visitasAtrasadas,
    required this.visitasConcluidasMes,
  });

  final int familias;
  final int membros;
  final int gestantes;
  final int hipertensos;
  final int diabeticos;
  final int vacinasPendentes;
  final int vacinasAgendadas;
  final int vacinasConcluidas;
  final int visitasHoje;
  final int visitasAgendadas;
  final int visitasAtrasadas;
  final int visitasConcluidasMes;

  factory ResumoAgente.calcular({
    required List<Familia> familias,
    required List<Membro> membros,
    required List<VacinaTipo> tipos,
    required List<VacinaRegistro> registros,
    required List<Visita> visitas,
    required DateTime agora,
  }) {
    final membroIds = membros.map((m) => m.id).toSet();
    final tipoIds = tipos.map((t) => t.id).toSet();
    final validos = registros
        .where((r) => membroIds.contains(r.membroId) && tipoIds.contains(r.tipoId))
        .toList();
    final concluidas =
        validos.where((r) => r.status == StatusVacina.concluida).length;
    final agendadas =
        validos.where((r) => r.status == StatusVacina.agendada).length;

    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final fimHoje = inicioHoje.add(const Duration(days: 1));
    final abertas = visitas.where((v) => v.status == StatusVisita.agendada);

    return ResumoAgente(
      familias: familias.length,
      membros: membros.length,
      gestantes: membros.where((m) => m.gestante).length,
      hipertensos: membros
          .where((m) => m.doencas.contains(OpcoesMembro.hipertensao))
          .length,
      diabeticos:
          membros.where((m) => m.doencas.contains(OpcoesMembro.diabetes)).length,
      vacinasPendentes: membros.length * tipos.length - concluidas,
      vacinasAgendadas: agendadas,
      vacinasConcluidas: concluidas,
      visitasHoje: abertas
          .where((v) =>
              !v.agendadaPara.isBefore(inicioHoje) &&
              v.agendadaPara.isBefore(fimHoje))
          .length,
      visitasAgendadas: abertas.length,
      visitasAtrasadas:
          abertas.where((v) => v.agendadaPara.isBefore(inicioHoje)).length,
      visitasConcluidasMes: visitas.where((v) {
        if (v.status != StatusVisita.concluida) return false;
        final d = v.concluidaEm ?? v.agendadaPara;
        return d.year == agora.year && d.month == agora.month;
      }).length,
    );
  }
}
