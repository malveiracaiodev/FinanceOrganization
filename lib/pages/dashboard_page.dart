import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onSelectTab;

  const DashboardPage({super.key, this.onSelectTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool carregando = true;
  Usuario? usuario;
  ControleFinanceiro? controle;
  double saldoReal = 0.0;

  @override
  void initState() {
    super.initState();
    carregarDados(); // 🔥 CORRIGIDO: Removido o "_" para apontar para a função real
  }

  // 🔥 Mudamos para público para que a NavegacaoPage ou modais centrais possam forçar o refresh se necessário
  Future<void> carregarDados() async {
    try {
      final resUsuario = await PreferencesService.carregarUsuario();
      final resControle = await ControleService.carregarControle();

      if (!mounted) return;

      setState(() {
        usuario = resUsuario;
        controle = resControle;
        
        // Calcula o saldo dinâmico baseado nos dados carregados
        final ganhoFixo = resUsuario?.ganhoFixo ?? 0.0;
        final receitasExtras = resControle.receitasExtras;
        final despesas = resControle.despesas;
        
        saldoReal = (ganhoFixo + receitasExtras) - despesas;
        carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dados do painel: $e");
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Soma de Entradas protegendo contra nulos
    final totalEntradas = (usuario?.ganhoFixo ?? 0.0) + (controle?.receitasExtras ?? 0.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab),
      backgroundColor: Colors.transparent, // 🔥 CORRIGIDO: Transparente para revelar o FundoCosmico por baixo
      body: FundoCosmico(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
              : SafeArea(
                  child: Column(
                    children: [
                      // 🛸 Barra de Topo Executiva Stitch
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            ),
                            const Text(
                              "PAINEL GERENCIAL",
                              style: TextStyle(
                                color: Color(0xFF00B4D8), // Unificado com o Neon do ecossistema
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 24), // Trocado notificação por botão útil de Refresh manual
                              onPressed: carregarDados, // 🔥 CORRIGIDO: Removido o "_"
                            ),
                          ],
                        ),
                      ),

                      // 🌌 Área de Rolagem Dinâmica
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFF00B4D8),
                          backgroundColor: const Color(0xFF070D19),
                          onRefresh: carregarDados, // 🔥 CORRIGIDO: Removido o "_"
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                
                                // 💎 CARD PRINCIPAL: SALDO CONSOLIDADO NEON
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1424).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00B4D8).withValues(alpha: 0.03),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "SALDO ATUAL CONSOLIDADO",
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "R\$ ${saldoReal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Color(0xFF8CE8FF), // Ciano brilhante para leitura numérica
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00B4D8).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.shield_outlined, color: Color(0xFF00B4D8), size: 14),
                                            SizedBox(width: 6),
                                            Text(
                                              "Ambiente Operacional Seguro",
                                              style: TextStyle(color: Color(0xFF00B4D8), fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Card informativo secundário de Acúmulo
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF070D19).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_upward_rounded, color: Color(0xFF8CE8FF), size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Entradas acumuladas neste ciclo: R\$ ${totalEntradas.toStringAsFixed(2)}",
                                          style: const TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'monospace'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}