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

  // 🛰️ Lista oficial organizada conforme o layout padrão do Mark I (Imagem screen.png)
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF060B16),
      appBar: AppBar(
        title: Text(
          _tituloAppBar,
          style: const TextStyle(letterSpacing: 1.5, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1128),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF00B4D8)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      
      // 🎯 CORREÇÃO CRÍTICA: Injetando o callback para o AppDrawer conseguir mudar as abas
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
            color: const Color(0xFF0A1128),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 🛸 Botões remodelados e reordenados com base na imagem screen.png do projeto
                _buildBottomActionItem(index: 0, icone: Icons.home_filled, label: "Home"),
                _buildBottomActionItem(index: 1, icone: Icons.history_toggle_off_rounded, label: "History"),
                _buildBottomActionItem(index: 2, icone: Icons.add_circle_outline_rounded, label: "Add"),
                _buildBottomActionItem(index: 3, icone: Icons.settings_outlined, label: "Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionItem({required int index, required IconData icone, required String label}) {
    final bool ativo = _currentIndex == index;
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
              color: ativo ? const Color(0xFF00B4D8) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: ativo ? const Color(0xFF00B4D8) : Colors.white38, 
                fontSize: 10,
                fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}