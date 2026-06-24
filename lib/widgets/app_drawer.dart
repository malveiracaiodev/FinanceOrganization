import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/historico_page.dart';
import '../pages/parcelas_page.dart'; // 🔥 Nova aba de parcelamentos

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _abrirSite() async {
    final url = Uri.parse('https://malveiracaiodev.github.io');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // Fecha o drawer primeiro para evitar travamento visual

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF070B14), // Fundo espacial profundo escuro
      child: Column(
        children: [
          const SizedBox(height: 60),

          // 🌌 Cabeçalho Orbital do Drawer
          const Text(
            'FinanceControl',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'MARK I • PAINEL DE CONTROLE',
            style: TextStyle(
              color: AstraTheme.secondary,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(color: Colors.white10, height: 1),
          ),
          const SizedBox(height: 16),

          // 🎛️ Itens de Navegação
          ListTile(
            leading: const Icon(Icons.rocket_launch, color: AstraTheme.primary),
            title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _navigate(context, const DashboardPage()),
          ),

          ListTile(
            leading: const Icon(Icons.credit_card, color: AstraTheme.primary),
            title: const Text('Compras Parceladas', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _navigate(context, const ParcelasPage()),
          ),

          ListTile(
            leading: const Icon(Icons.history, color: AstraTheme.primary),
            title: const Text('Histórico Mensal', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _navigate(context, const HistoricoPage()),
          ),

          ListTile(
            leading: const Icon(Icons.language, color: AstraTheme.primary),
            title: const Text('Desenvolvedor (Site)', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: _abrirSite,
          ),

          const Spacer(),

          // 🛡️ Rodapé de Identidade do Comandante
          const Text(
            'SISTEMA OPERACIONAL',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'v1.0.0',
            style: TextStyle(
              color: Colors.white12,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}