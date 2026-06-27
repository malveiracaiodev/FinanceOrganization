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

  void _mudarAbaExterna(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// 🔥 CENTRAL DE COMANDOS: Abre o painel inferior para lançar novos dados
  void _abrirPainelLancamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF070D19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "NOVA OPERAÇÃO OTIMIZADA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botão de Adicionar Ganho
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.arrow_upward_rounded, color: Color(0xFF060B16)),
                  ),
                  title: const Text("Registrar Receita / Ganho", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Chamar o formulário ou dialog do ControleService para Receita
                    debugPrint("Abre formulário de Receita");
                  },
                ),
                const Divider(color: Colors.white10),
                
                // Botão de Adicionar Gasto
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.arrow_downward_rounded, color: Color(0xFF060B16)),
                  ),
                  title: const Text("Registrar Despesa / Gasto", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Chamar o formulário ou dialog do ControleService para Despesa
                    debugPrint("Abre formulário de Despesa");
                  },
                ),
                const Divider(color: Colors.white10),
                
                // Botão de Adicionar Contrato/Parcela
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00B4D8),
                    child: Icon(Icons.credit_card_rounded, color: Color(0xFF060B16)),
                  ),
                  title: const Text("Novo Contrato Parcelado", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Move o usuário para a aba de parcelas e pode abrir o criador
                    _mudarAbaExterna(1);
                    debugPrint("Abre formulário de Parcela");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [
      DashboardPage(onSelectTab: _mudarAbaExterna), 
      ParcelasPage(onSelectTab: _mudarAbaExterna),  
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
                _buildBottomActionItem(index: 0, icone: Icons.rocket_launch_rounded, label: "Dashboard"), 
                _buildBottomActionItem(index: 1, icone: Icons.credit_card_rounded, label: "Contratos"),
                
                // ➕ Botão Central Conectado com o Modal Operacional
                GestureDetector(
                  onTap: () => _abrirPainelLancamento(context), // 🔥 CONECTADO!
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF060B16), 
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00B4D8), width: 2), 
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
              color: ativo ? const Color(0xFF00B4D8) : Colors.white38, 
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