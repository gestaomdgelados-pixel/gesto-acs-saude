import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/familia.dart';
import '../models/questionario_visita.dart';
import '../models/visita.dart';

class RelatorioVisitasService {
  Future<void> compartilhar({
    required DateTime mes,
    required List<Visita> visitas,
    required List<Familia> familias,
    required String agente,
  }) async {
    final bytes = await gerar(
        mes: mes, visitas: visitas, familias: familias, agente: agente);
    final nome = 'relatorio-visitas-${DateFormat('yyyy-MM').format(mes)}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: nome);
  }

  Future<Uint8List> gerar({
    required DateTime mes,
    required List<Visita> visitas,
    required List<Familia> familias,
    required String agente,
  }) {
    final nomeMes = DateFormat("MMMM 'de' yyyy", 'pt_BR').format(mes);
    final porId = {for (final f in familias) f.id: f};
    int conta(StatusVisita s) => visitas.where((v) => v.status == s).length;

    final doc = pw.Document(title: 'Relatório de visitas - $nomeMes', author: agente);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text('Relatório mensal de visitas domiciliares',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Agente: $agente'),
          pw.Text('Período: $nomeMes'),
          pw.Text(
              'Gerado em: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.now())}'),
          pw.SizedBox(height: 10),
          pw.Text(
              'Resumo: ${visitas.length} visita(s) - ${conta(StatusVisita.concluida)} concluída(s), '
              '${conta(StatusVisita.naoRealizada)} não realizada(s), '
              '${conta(StatusVisita.agendada)} pendente(s)'),
          pw.Divider(),
          for (final v in visitas) ..._bloco(v, porId[v.familiaId]),
        ],
      ),
    );
    return doc.save();
  }

  List<pw.Widget> _bloco(Visita v, Familia? f) {
    final formato = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final negrito = pw.TextStyle(fontWeight: pw.FontWeight.bold);
    final linhas = <pw.Widget>[
      pw.Text(
        '${formato.format(v.agendadaPara)} - ${f?.responsavel ?? 'Família removida'}',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      if (f != null) pw.Text('Endereço: ${f.endereco}'),
      pw.Text('Motivo: ${v.motivo}'),
      pw.Text('Situação: ${_situacao(v)}'),
    ];
    if (v.status == StatusVisita.naoRealizada) {
      linhas.add(pw.Text('Justificativa: ${v.justificativa ?? ''}'));
    }
    if (v.status == StatusVisita.concluida) {
      final c = v.concluidaEm;
      if (c != null) linhas.add(pw.Text('Concluída em: ${formato.format(c)}'));
      for (final p in QuestionarioVisita.perguntas) {
        final r = v.respostas[p.id];
        if (r == null || r.trim().isEmpty) continue;
        linhas.add(pw.SizedBox(height: 3));
        linhas.add(pw.Text(p.titulo, style: negrito));
        linhas.add(pw.Text(r));
      }
    }
    linhas.add(pw.Divider());
    return linhas;
  }

  String _situacao(Visita v) => switch (v.status) {
        StatusVisita.concluida => 'Concluída',
        StatusVisita.naoRealizada => 'Não realizada',
        StatusVisita.agendada => 'Pendente (sem conclusão nem justificativa)',
      };
}
