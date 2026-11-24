import '../models/arquivo_escolhido.dart';
import '../models/documento.dart';
import '../repositories/arquivo_repository.dart';
import '../repositories/documento_repository.dart';
import 'erros.dart';
import 'safe_notifier.dart';

class DocumentosProvider extends SafeNotifier {
  DocumentosProvider(this._repo, this._arquivos, {required this.recebidos});

  final DocumentoRepository _repo;
  final ArquivoRepository _arquivos;
  final bool recebidos;
  static const _limite = 20 * 1024 * 1024;

  List<Documento> itens = [];
  bool carregando = false;
  String? erro;

  int get novos =>
      recebidos ? itens.where((d) => d.vistoEm == null).length : 0;

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await _repo.listar(recebidos: recebidos);
      final chegaram = [
        for (final d in itens)
          if (recebidos && d.recebidoEm == null) d.id,
      ];
      if (chegaram.isNotEmpty) {
        await _repo.marcar('recebido_em', chegaram);
        itens = await _repo.listar(recebidos: recebidos);
      }
    } catch (e) {
      erro = mensagemDeErro(e);
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<(ArquivoEscolhido?, String?)> escolherPdf() async {
    try {
      final a = await _arquivos.escolher(extensoes: ['pdf']);
      if (a != null && a.bytes.length > _limite) {
        return (null, 'O PDF passa de 20 MB. Escolha um arquivo menor.');
      }
      return (a, null);
    } catch (e) {
      return (null, mensagemDeErro(e));
    }
  }

  Future<String?> enviar(
      ArquivoEscolhido a, String usuario, String meuNome) async {
    try {
      await _repo.enviar(a, usuario, meuNome);
      await carregar();
      return null;
    } catch (e) {
      return mensagemDeErro(e);
    }
  }

  /// Marca como visto (para quem recebeu) e devolve o link do PDF.
  Future<({String? url, String? erro})> abrir(Documento d) async {
    try {
      if (recebidos && d.vistoEm == null) {
        await _repo.marcar('visto_em', [d.id]);
        await carregar();
      }
      return (url: await _repo.link(d.caminho), erro: null);
    } catch (e) {
      return (url: null, erro: mensagemDeErro(e));
    }
  }
}
