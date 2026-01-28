import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_drawer.dart'; // seu Drawer reutilizável
import 'fundo_cosmico.dart'; // fundo cósmico animado

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // menu lateral
      body: FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Texto de boas-vindas
              const Text(
                "Bem-vindo ao Finance Organization",
                style: TextStyle(color: Colors.cyan, fontSize: 22),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Texto pulsante "Mark I"
              Text(
                "Mark I",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),

              const SizedBox(height: 40),

              // Logo abaixo
              Image.asset(
                "assets/meu_logotipo.png",
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
