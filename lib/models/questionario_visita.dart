enum TipoPergunta { escolha, texto }

class Pergunta {
  const Pergunta({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.opcoes = const [],
    this.obrigatoria = false,
  });

  final String id;
  final String titulo;
  final TipoPergunta tipo;
  final List<String> opcoes;
  final bool obrigatoria;
}

class QuestionarioVisita {
  QuestionarioVisita._();

  static const perguntas = [
    Pergunta(
      id: 'quem_atendeu',
      titulo: 'Quem foi atendido na visita?',
      tipo: TipoPergunta.texto,
      obrigatoria: true,
    ),
    Pergunta(
      id: 'situacao',
      titulo: 'Como estava a situação geral da família?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Tudo bem', 'Precisa de atenção', 'Situação de risco'],
      obrigatoria: true,
    ),
    Pergunta(
      id: 'doentes',
      titulo: 'Havia alguém doente ou com sintomas?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Não', 'Sim'],
      obrigatoria: true,
    ),
    Pergunta(
      id: 'sintomas',
      titulo: 'Quais sintomas ou queixas foram relatados?',
      tipo: TipoPergunta.texto,
    ),
    Pergunta(
      id: 'medicacao',
      titulo: 'Os medicamentos de uso contínuo estão sendo tomados?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Sim', 'Não', 'Não se aplica'],
    ),
    Pergunta(
      id: 'vacinas',
      titulo: 'As vacinas da família estão em dia?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Sim', 'Parcialmente', 'Não'],
      obrigatoria: true,
    ),
    Pergunta(
      id: 'gestante',
      titulo: 'Há gestante ou recém-nascido na casa?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Não', 'Gestante', 'Recém-nascido', 'Os dois'],
    ),
    Pergunta(
      id: 'moradia',
      titulo: 'Como estão as condições da moradia (água, esgoto, lixo)?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Adequadas', 'Parcialmente adequadas', 'Inadequadas'],
    ),
    Pergunta(
      id: 'foco',
      titulo: 'Foi encontrado foco do mosquito da dengue?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Não', 'Sim'],
    ),
    Pergunta(
      id: 'encaminhamento',
      titulo: 'Foi necessário encaminhar alguém ao posto ou hospital?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Não', 'Sim'],
      obrigatoria: true,
    ),
    Pergunta(
      id: 'encaminhamento_detalhe',
      titulo: 'Se sim: quem foi encaminhado, para onde e por quê?',
      tipo: TipoPergunta.texto,
    ),
    Pergunta(
      id: 'orientacoes',
      titulo: 'Quais orientações foram dadas à família?',
      tipo: TipoPergunta.texto,
      obrigatoria: true,
    ),
    Pergunta(
      id: 'retorno',
      titulo: 'É preciso voltar à casa em breve?',
      tipo: TipoPergunta.escolha,
      opcoes: ['Não', 'Sim, em até 7 dias', 'Sim, em até 30 dias'],
    ),
    Pergunta(
      id: 'observacoes',
      titulo: 'Observações gerais sobre a visita',
      tipo: TipoPergunta.texto,
    ),
  ];
}
