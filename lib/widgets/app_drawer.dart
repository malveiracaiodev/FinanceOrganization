import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

import '../../services/preferences_service.dart';
import '../../pages/historico_page.dart';
import '../../pages/controle_page.dart';

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
    Navigator.pop(context); // fecha drawer primeiro

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0F1E),
      child: Column(
        children: [
          const SizedBox(height: 50),

          Text(
            'Finance Organization',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Controle Financeiro Pessoal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: AppTheme.primaryColor),

          ListTile(
            leading: Icon(Icons.dashboard, color: AppTheme.primaryColor),
            title: const Text('Controle',
                style: TextStyle(color: Colors.white)),
            onTap: () => _navigate(context, const ControlePage()),
          ),

          ListTile(
            leading: Icon(Icons.settings, color: AppTheme.primaryColor),
            title: const Text('Configurações',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/preferences');
            },
          ),

          ListTile(
            leading: Icon(Icons.history, color: AppTheme.primaryColor),
            title: const Text('Histórico',
                style: TextStyle(color: Colors.white)),
            onTap: () => _navigate(context, const HistoricoPage()),
          ),

          ListTile(
            leading: Icon(Icons.web, color: AppTheme.primaryColor),
            title: const Text('Meu Site',
                style: TextStyle(color: Colors.white)),
            onTap: _abrirSite,
          ),

          const Spacer(),

          Text(
            'MARK I',
            style: TextStyle(
              color: AppTheme.secondaryColor,
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Image.asset(
            'assets/meu_logotipo.png',
            height: 90,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}