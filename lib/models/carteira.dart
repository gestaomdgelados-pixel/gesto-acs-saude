import 'vacina.dart';

enum SituacaoVacina { atrasada, agendada, pendente, concluida }

extension SituacaoVacinaTexto on SituacaoVacina {
  String get rotulo => switch (this) {
        SituacaoVacina.atrasada => 'Atrasada',
        SituacaoVacina.agendada => 'Agendada',
        SituacaoVacina.pendente => 'Pendente',
        SituacaoVacina.concluida => 'Concluída',
      };
}

extension VacinaItemCarteira on VacinaItem {
  SituacaoVacina get situacao {
    final r = registro;
    if (r == null) return SituacaoVacina.pendente;
    if (r.status == StatusVacina.concluida) return SituacaoVacina.concluida;
    final d = r.dataPrevista;
    final h = DateTime.now();
    if (d != null && d.isBefore(DateTime(h.year, h.month, h.day))) {
      return SituacaoVacina.atrasada;
    }
    return SituacaoVacina.agendada;
  }
}
