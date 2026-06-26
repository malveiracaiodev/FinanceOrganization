import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B16),
      appBar: AppBar(
        title: const Text(
          "SISTEMA CENTRAL",
          style: TextStyle(letterSpacing: 1.5, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF0A1128),
        elevation: 0,
      ),
      drawer: const AppDrawer(), // Componente drawer corrigido acima
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: Color(0xFF00B4D8),
              ),
              const SizedBox(height: 24),
              const Text(
                "Interface Inicializada",
                textAlign: TextAlign.center, // 🔥 Corrigido de 'Center' para 'TextAlign.center'
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "A órbita financeira e os fluxos de caixa da Mark I estão sob monitorização constante.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0), // 🔥 Corrigido de 'EdgeInsets.bottom' para 'EdgeInsets.only'
                child: Text(
                  "Versão do Núcleo: v1.0.0+1",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF00B4D8).withValues(alpha: 0.5),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}