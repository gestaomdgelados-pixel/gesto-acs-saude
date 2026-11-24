import 'package:intl/intl.dart';

String dataCurta(DateTime d) => DateFormat('dd/MM/yyyy', 'pt_BR').format(d);

String dataHora(DateTime d) =>
    DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(d);

String hora(DateTime d) => DateFormat('HH:mm', 'pt_BR').format(d);

String dataExtensa(DateTime d) =>
    DateFormat("EEE, d 'de' MMM · HH:mm", 'pt_BR').format(d);

String mesAno(DateTime d) =>
    toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'pt_BR').format(d)) ?? '';
