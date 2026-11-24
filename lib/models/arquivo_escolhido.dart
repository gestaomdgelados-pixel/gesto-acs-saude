import 'dart:typed_data';

class ArquivoEscolhido {
  const ArquivoEscolhido(this.bytes, this.nome);

  final Uint8List bytes;
  final String nome;

  String get extensao =>
      nome.contains('.') ? nome.split('.').last.toLowerCase() : '';
}
