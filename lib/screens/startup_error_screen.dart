import 'package:flutter/material.dart';

import '../widgets/common/error_banner.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.mensagem});
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão ACS Saúde')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ErrorBanner(mensagem: mensagem),
          ),
        ),
      ),
    );
  }
}
