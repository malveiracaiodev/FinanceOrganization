import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;

  const AppDrawer({
    super.key,
    this.onSelectTab,
  });

  /// 🌐 Método seguro para abrir o site orbital externo
  Future<void> _abrirLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Não foi possível abrir o link $url';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao abrir link externo: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF060B16), // Fundo cibernético
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0A1128),
              ),
              child: Row(
                children: [
                  // 🚀 SEU LOGOTIPO AQUI
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/meu_logotipo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Caso a imagem falhe ou não seja achada, mostra o ícone de fallback para não quebrar o app
                        return const Icon(
                          Icons.terminal_rounded,
                          color: Color(0xFF00B4D8),
                          size: 45,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "FINANÇAS MARK I",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Controle de Missão",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF00B4D8)),
              title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onSelectTab != null) onSelectTab!(0);
              },
            ),

            ListTile(
              leading: const Icon(Icons.language_rounded, color: Color(0xFF00B4D8)),
              title: const Text("Meu Site Pessoal", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // 🔗 Seu site linkado direto aqui!
                _abrirLink(context, "https://malveiracaiodev.github.io/");
              },
            ),
          ],
        ),
      ),
    );
  }
}