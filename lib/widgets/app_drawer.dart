import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/configuracoes_page.dart'; // Importação do módulo de configurações

class AppDrawer extends StatelessWidget {
  final Function(int)? onSelectTab;

  const AppDrawer({super.key, this.onSelectTab});

  /// 🌐 Método de redirecionamento orbital para o seu portfólio externo
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
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.colorScheme.surface, // Integrado à cor de superfície do seu tema
        child: Column(
          children: [
            // Menu de Opções Estruturado
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 80),
                children: [
                  _buildItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: "Dashboard",
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(0);
                    },
                  ),
                  _buildItem(
                    context: context,
                    icon: Icons.history_toggle_off_rounded,
                    title: "Histórico de Missões",
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(1);
                    },
                  ),
                  _buildItem(
                    context: context,
                    icon: Icons.swap_horizontal_circle_outlined,
                    title: "Controle de Fluxo",
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(2);
                    },
                  ),
                  _buildItem(
                    context: context,
                    icon: Icons.credit_card_rounded,
                    title: "Contratos e Parcelas",
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelectTab != null) onSelectTab!(3);
                    },
                  ),
                  
                  const Divider(color: Colors.white12),

                  // ⚙️ IMPLEMENTADO: Acesso à nova tela de Configurações
                  _buildItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    title: "Configurações",
                    onTap: () {
                      Navigator.pop(context); // Fecha a gaveta lateral
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
                      );
                    },
                  ),

                  _buildItem(
                    context: context,
                    icon: Icons.code_rounded,
                    title: "MalveiraCaioDev",
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink(context); // Redirecionamento orbital externo
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
                    'assets/meu_logotipo.png', // Lembre-se de checar o registro no pubspec.yaml
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

  // Widget auxiliar privado para padronização dos itens da gaveta lateral
  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.primaryColor), // Usa o ciano orbital padrão do tema
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Space Grotesk', // Coesão tipográfica estrita
        ),
      ),
      onTap: onTap,
    );
  }
}