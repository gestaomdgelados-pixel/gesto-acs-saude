import 'familia.dart';
import 'membro.dart';
import 'vacina.dart';
import 'visita.dart';

enum TipoAlerta { visita, vacina, cadastroFamilia, cadastroPessoa }

/// Um item atrasado ou pendente mostrado no quadro de alertas do agente.
class AlertaAtraso {
  const AlertaAtraso({
    required this.tipo,
    required this.titulo,
    required this.detalhe,
    this.desde,
  });

  final TipoAlerta tipo;
  final String titulo;
  final String detalhe;
  final DateTime? desde;

  static bool _vazio(String? v) => v == null || v.trim().isEmpty;

  static List<AlertaAtraso> calcular({
    required List<Familia> familias,
    required List<Membro> membros,
    required List<VacinaTipo> tipos,
    required List<VacinaRegistro> registros,
    required List<Visita> visitas,
    required DateTime agora,
  }) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final nomeFamilia = {for (final f in familias) f.id: f.responsavel};
    final nomePessoa = {for (final m in membros) m.id: m.nome};
    final nomeVacina = {for (final t in tipos) t.id: t.nome};
    final lista = <AlertaAtraso>[];

    for (final v in visitas) {
      if (v.status == StatusVisita.agendada && v.atrasada) {
        lista.add(AlertaAtraso(
          tipo: TipoAlerta.visita,
          titulo: 'Visita atrasada · ${nomeFamilia[v.familiaId] ?? 'Família'}',
          detalhe: v.motivo,
          desde: v.agendadaPara,
        ));
      }
    }

    for (final r in registros) {
      final prevista = r.dataPrevista;
      if (r.status == StatusVacina.agendada &&
          prevista != null &&
          prevista.isBefore(hoje)) {
        lista.add(AlertaAtraso(
          tipo: TipoAlerta.vacina,
          titulo: 'Vacina atrasada · ${nomePessoa[r.membroId] ?? 'Pessoa'}',
          detalhe: nomeVacina[r.tipoId] ?? 'Vacina',
          desde: prevista,
        ));
      }
    }

    for (final f in familias) {
      final faltando = [
        if (_vazio(f.telefone)) 'telefone',
        if (_vazio(f.numero)) 'número',
        if (_vazio(f.bairro)) 'bairro',
        if (_vazio(f.microarea)) 'microárea',
      ];
      if (faltando.isNotEmpty) {
        lista.add(AlertaAtraso(
          tipo: TipoAlerta.cadastroFamilia,
          titulo: 'Cadastro incompleto · Família ${f.responsavel}',
          detalhe: 'Falta: ${faltando.join(', ')}',
        ));
      }
    }

    for (final m in membros) {
      final faltando = [
        if (m.nascimento == null) 'nascimento',
        if (_vazio(m.sexo)) 'sexo',
        if (_vazio(m.cartaoSus) && _vazio(m.cpf)) 'cartão SUS ou CPF',
        if (_vazio(m.parentesco)) 'parentesco',
      ];
      if (faltando.isNotEmpty) {
        lista.add(AlertaAtraso(
          tipo: TipoAlerta.cadastroPessoa,
          titulo: 'Cadastro incompleto · ${m.nome}',
          detalhe: 'Falta: ${faltando.join(', ')}',
        ));
      }
    }

    lista.sort((a, b) {
      final t = a.tipo.index.compareTo(b.tipo.index);
      if (t != 0) return t;
      if (a.desde == null || b.desde == null) return 0;
      return a.desde!.compareTo(b.desde!);
    });
    return lista;
  }
}
