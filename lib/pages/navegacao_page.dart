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

  final List<Widget> _telas = [
    const DashboardPage(), // Aba 0
    const ParcelasPage(),  // Aba 1
    const Center(child: Text("STATS EM DESENVOLVIMENTO", style: TextStyle(color: Colors.white54))),
    const Center(child: Text("CONFIGURAÇÕES", style: TextStyle(color: Colors.white54))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B16),
      body: IndexedStack(
        index: _currentIndex,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF070D19),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04), width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomActionItem(index: 0, icone: Icons.home_filled, label: "Home"),
                _buildBottomActionItem(index: 1, icone: Icons.history, label: "Contratos"),
                
                // ➕ Botão Central de Nova Operação (Magnitude/Vetor)
                GestureDetector(
                  onTap: () {
                    // Chamar modal de lançamentos futuramente
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF060B16), size: 28),
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
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: ativo ? const Color(0xFF00E5FF) : Colors.white38, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: ativo ? const Color(0xFF00E5FF) : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}