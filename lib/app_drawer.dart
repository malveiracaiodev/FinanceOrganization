import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Importa suas páginas
import 'configuracoes_page.dart';
import 'historico_page.dart';
import 'controle_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _abrirSite() async {
    final url = Uri.parse("https://malveiracaiodev.github.io");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Finance Organization",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.cyan),

          // Botões de navegação
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.cyan),
            title:
                const Text("Controle", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ControlePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.cyan),
            title: const Text("Configurações Pessoais",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.cyan),
            title: const Text("Histórico Mensal",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricoPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.web, color: Colors.cyan),
            title:
                const Text("Meu Site", style: TextStyle(color: Colors.white)),
            onTap: _abrirSite,
          ),

          const Spacer(),

          // Texto Mark I pulsante
          const AnimatedPulseText(),

          const SizedBox(height: 20),

          // Logotipo abaixo
          Image.asset(
            "assets/meu_logotipo.png", // corrigido para underscore
            height: 100,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Texto pulsante "Mark I"
class AnimatedPulseText extends StatefulWidget {
  const AnimatedPulseText({super.key});

  @override
  State<AnimatedPulseText> createState() => _AnimatedPulseTextState();
}

class _AnimatedPulseTextState extends State<AnimatedPulseText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Text(
        "Mark I",
        style: TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.redAccent, blurRadius: 20),
            Shadow(color: Colors.orange, blurRadius: 40),
          ],
        ),
      ),
    );
  }
}
