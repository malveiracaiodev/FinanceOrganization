import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  // 🔥 Adicionado o parâmetro requisitado pelas suas páginas de Dashboard e Parcelas
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
    final theme = Theme.of(context);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.terminal_rounded,
                    color: Color(0xFF00B4D8),
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "FINANÇAS MARK I",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "Painel de Controlo de Missão",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Exemplo de como usar o onSelectTab se precisar mudar para a aba Home (0), por exemplo:
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF00B4D8)),
              title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onSelectTab != null) onSelectTab!(0); // Navega para o Hub principal se fornecido
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF00B4D8)),
              title: const Text("Suporte & Documentação", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _abrirLink(context, "https://github.com");
              },
            ),
          ],
        ),
      ),
    );
  }
}