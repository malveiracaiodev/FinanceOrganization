import 'package:flutter/material.dart';
import 'url_launcher/url_launcher.dart'; // Mantendo sua importação original

import '../core/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  // 🔥 Callback que avisa o Hub de abas qual índice deve ser aberto
  final Function(int)? onSelectTab;

  const AppDrawer({
    super.key,
    this.onSelectTab,
  });

  Future<void> _abrirSite() async {
    final Uri url = Uri.parse('https://malveiracaiodev.github.io');
    
    try {
      // Usar diretamente o launchUrl sem o canLaunchUrl evita travar em restrições do Android nativo
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Erro ao abrir link: $e");
    }
  }

  void _mudarAba(BuildContext context, int index) {
    Navigator.pop(context); // Fecha o painel lateral com suavidade
    if (onSelectTab != null) {
      onSelectTab!(index); // Dispara a troca da aba ativa no Hub central
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF070B14), // Fundo espacial profundo escuro do Stitch
      child: Column(
        children: [
          const SizedBox(height: 50),

          // 🪐 LOGO COM ESTILO STITCH (Injetado e Estilizado)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00B4D8), width: 1.5), // Borda Neon Ciano
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.3),
                  blurRadius: 10,
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                'assets/meu_logotipo.png', // Altere para o caminho exato do seu arquivo de logo
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Se a imagem sumir ou o caminho estiver errado, exibe um ícone espacial de backup
                  return const Icon(Icons.rocket_launch, color: Color(0xFF00B4D8), size: 30);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🌌 Cabeçalho Orbital do Drawer
          const Text(
            'FinanceControl',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'MARK I • PAINEL DE CONTROLE',
            style: TextStyle(
              color: AstraTheme.secondary,
              fontSize: 10,
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

          // 🎛️ Itens de Navegação Sincronizados com as Abas do Stitch
          ListTile(
            leading: const Icon(Icons.rocket_launch, color: AstraTheme.primary),
            title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _mudarAba(context, 0),
          ),

          ListTile(
            leading: const Icon(Icons.credit_card, color: AstraTheme.primary),
            title: const Text('Compras Parceladas', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _mudarAba(context, 1),
          ),

          ListTile(
            leading: const Icon(Icons.history, color: AstraTheme.primary),
            title: const Text('Histórico Mensal', style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () => _mudarAba(context, 2),
          ),

          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF00B4D8)), // Ciano Stitch para destacar o link
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