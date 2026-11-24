import 'package:flutter/material.dart';

import '../documentos_tab.dart';

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos para a gestão')),
      body: const SafeArea(child: DocumentosTab(recebidos: false)),
    );
  }
}
