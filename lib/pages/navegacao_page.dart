import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'controle_page.dart';
import 'parcelas_page.dart'; 
import 'historico_page.dart';
import '../widgets/app_drawer.dart';

class NavegacaoPage extends StatefulWidget {
  const NavegacaoPage({super.key});

  @override
  State<NavegacaoPage> createState() => _NavegacaoPageState();
}

class _NavegacaoPageState extends State<NavegacaoPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _mudarAbaExterna(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 🛰️ Lista oficial organizada conforme o layout padrão do Mark I
  List<Widget> get _paginas => [
    DashboardPage(onSelectTab: _mudarAbaExterna), // 0: Home
    HistoricoPage(onSelectTab: _mudarAbaExterna), // 1: History
    ControlePage(onSelectTab: _mudarAbaExterna),  // 2: Add
    ParcelasPage(onSelectTab: _mudarAbaExterna),  // 3: Settings/Cartões
  ];

  String get _tituloAppBar {
    switch (_currentIndex) {
      case 0: return "PAINEL CENTRAL";
      case 1: return "HISTÓRICO DE MISSÕES";
      case 2: return "CONTROLE DE FLUXO";
      case 3: return "CONTRATOS E PARCELAS";
      default: return "SISTEMA CENTRAL";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor, // Integrado ao tema
      
      appBar: AppBar(
        title: Text(_tituloAppBar),
        backgroundColor: Colors.transparent, // Transparência para fusão com o fundo cósmico
        elevation: 0,
        scrolledUnderElevation: 0, // Evita mudança de cor ao rolar listas sob o app bar
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          color: theme.primaryColor, // Ciano Elétrico extraído dinamicamente do tema
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      
      // 🎯 Injeção do callback para o AppDrawer interagir com a navegação central
      drawer: AppDrawer(onSelectTab: _mudarAbaExterna),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _paginas,
      ),
      
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95), // Superfície translúcida do tema
            borderRadius: BorderRadius.circular(24), // Cantos modernos de 24px que casam com os cards
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.15), // Borda de brilho sutil baseada no tema
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomActionItem(
                  context: context,
                  index: 0, 
                  icone: Icons.home_filled, 
                  label: "Home",
                ),
                _buildBottomActionItem(
                  context: context,
                  index: 1, 
                  icone: Icons.history_toggle_off_rounded, 
                  label: "History",
                ),
                _buildBottomActionItem(
                  context: context,
                  index: 2, 
                  icone: Icons.add_circle_outline_rounded, 
                  label: "Add",
                ),
                _buildBottomActionItem(
                  context: context,
                  index: 3, 
                  icone: Icons.settings_outlined, 
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Componente individual dos botões de ação na barra inferior flutuante
  Widget _buildBottomActionItem({
    required BuildContext context,
    required int index, 
    required IconData icone, 
    required String label,
  }) {
    final theme = Theme.of(context);
    final bool ativo = _currentIndex == index;
    final color = ativo ? theme.primaryColor : Colors.white38;

    return GestureDetector(
      onTap: () => _mudarAbaExterna(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone, 
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: color, 
                fontSize: 10,
                fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Space Grotesk', // Garante a tipografia consistente com o restante do app
              ),
            ),
          ],
        ),
      ),
    );
  }
}