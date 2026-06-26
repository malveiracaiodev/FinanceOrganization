import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'parcelas_page.dart'; 

class NavegacaoPage extends StatefulWidget {
  const NavegacaoPage({super.key});

  @override
  State<NavegacaoPage> createState() => _NavegacaoPageState();
}

class _NavegacaoPageState extends State<NavegacaoPage> {
  int _currentIndex = 0;

  // 🔥 Método público ou gatilho interno para forçar a atualização de estado entre as abas
  void _mudarAbaExterna(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos as telas passando o callback dinamicamente para sincronizar o Drawer lateral
    final List<Widget> telas = [
      DashboardPage(onSelectTab: _mudarAbaExterna), // Aba 0
      ParcelasPage(onSelectTab: _mudarAbaExterna),  // Aba 1
      const Center(child: Text("STATS EM DESENVOLVIMENTO", style: TextStyle(color: Colors.white54))),
      const Center(child: Text("CONFIGURAÇÕES", style: TextStyle(color: Colors.white54))),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060B16),
      body: IndexedStack(
        index: _currentIndex,
        children: telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF070D19),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.04), width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomActionItem(index: 0, icone: Icons.rocket_launch_rounded, label: "Dashboard"), // Ícone espacial Stitch
                _buildBottomActionItem(index: 1, icone: Icons.credit_card_rounded, label: "Contratos"),
                
                // ➕ Botão Central de Nova Operação Estilo Stitch Neon
                GestureDetector(
                  onTap: () {
                    // 🔥 Chamar modal de lançamentos (Receitas/Despesas/Parcelas) futuramente
                    debugPrint("🔥 Abrindo central de comandos de novos lançamentos...");
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF060B16), // Fundo profundo
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00B4D8), width: 2), // Borda Neon Ciano Stitch
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4D8).withValues(alpha: 0.4), 
                          blurRadius: 10, 
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Color(0xFF00B4D8), size: 28),
                  ),
                ),
                
                _buildBottomActionItem(index: 2, icone: Icons.bar_chart_outlined, label: "Stats"),
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
              color: ativo ? const Color(0xFF00B4D8) : Colors.white38, // Centralizado na paleta azul ciano
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: ativo ? const Color(0xFF00B4D8) : Colors.white38, 
                fontSize: 10, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}