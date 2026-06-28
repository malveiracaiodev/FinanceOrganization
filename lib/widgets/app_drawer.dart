import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;

  const AppDrawer({super.key, this.onSelectTab});

  /// 🌐 Método de redirecionamento orbital para o seu portfólio
  Future<void> _abrirLink(BuildContext context) async {
    final Uri uri = Uri.parse("https://malveiracaiodev.github.io/");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Não foi possível acessar a órbita externa.';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao acessar portfólio: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF060B16),
        child: Column(
          children: [
            // Navegação Centralizada
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 80),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF00B4D8)),
                    title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history_rounded, color: Color(0xFF00B4D8)),
                    title: const Text("Histórico de Missões", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(1);
                    },
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.code_rounded, color: Color(0xFF00B4D8)),
                    title: const Text("MalveiraCaioDev", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink(context); // 🚀 Link direto para o seu site
                    },
                  ),
                ],
              ),
            ),

            // Rodapé com o Logo Banner
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/meu_logotipo.png', // Verifique este caminho!
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Versão Mark I",
                    style: TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}