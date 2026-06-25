import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../models/controle_financeiro.dart';
import '../../services/preferences_service.dart';
import '../../services/controle_service.dart';
import '../../services/parcelas_service.dart'; 
import '../../widgets/app_drawer.dart';
import '../../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onSelectTab; // 🔥 Callback para controle unificado da navegação

  const DashboardPage({super.key, this.onSelectTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Usuario? usuario;
  ControleFinanceiro? controle;
  double totalParcelasMes = 0;
  bool carregando = true;
  final int _currentBottomIndex = 0; // Index padrão desta página no fluxo de abas

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final user = await PreferencesService.carregarUsuario();
    final ctrl = await ControleService.carregarControle();
    final parcelas = await ParcelasService.calcularTotalMes();

    if (!mounted) return;

    setState(() {
      usuario = user;
      controle = ctrl;
      totalParcelasMes = parcelas;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final saldoReal = controle != null && usuario != null
        ? controle!.saldoFinal(usuario!.ganhoFixo, totalParcelasDoMes: totalParcelasMes)
        : 0.0;

    // Cálculo dinâmico para o medidor circular de orçamento
    final totalGasto = controle != null ? (controle!.despesas + totalParcelasMes) : 0.0;
    final orcamentoTotal = usuario != null ? usuario!.ganhoFixo : 1.0;
    final double percentualConsumido = (totalGasto / orcamentoTotal).clamp(0.0, 1.0);
    final double restanteOrcamento = (orcamentoTotal - totalGasto).clamp(0.0, double.infinity);

    // Soma correta de Entradas protegendo contra nulos
    final totalEntradas = (usuario?.ganhoFixo ?? 0.0) + (controle?.receitasExtras ?? 0.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab), // 🔥 Sincronizado
      backgroundColor: const Color(0xFF060B16),
      body: FundoCosmico(
        child: carregando
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : SafeArea(
                child: Column(
                  children: [
                    // 🛸 Barra de Topo Executiva
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const Text(
                            "PAINEL GERENCIAL",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          IconButton(
                            const Icon(Icons.notifications_none_outlined, color: Colors.white70, size: 24),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // 🌌 Área de Rolagem do Painel
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            
                            // 💎 CARD PRINCIPAL: SALDO CONSOLIDADO
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1424).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AstraTheme.primary.withOpacity(0.15)),
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
                                  const SizedBox(height: 10),
                                  Text(
                                    "R\$ ${saldoReal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF8CE8FF),
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AstraTheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shield_outlined, color: AstraTheme.primary, size: 14),
                                        SizedBox(width: 6),
                                        Text(
                                          "Ambiente Operacional Seguro",
                                          style: TextStyle(color: AstraTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),

                            // 📉 CARD DE ENTRADAS
                            _buildVerticalFluxCard(
                              titulo: "ENTRADAS TOTAIS",
                              valor: "R\$ ${totalEntradas.toStringAsFixed(2)}",
                              corLinha: const Color(0xFF00E5FF),
                              icone: Icons.arrow_downward,
                            ),

                            const SizedBox(height: 16),

                            // 📈 CARD DE SAÍDAS
                            _buildVerticalFluxCard(
                              titulo: "SAÍDAS TOTAIS",
                              valor: "R\$ ${totalGasto.toStringAsFixed(2)}",
                              corLinha: const Color(0xFFFF8C8C),
                              icone: Icons.arrow_upward,
                            ),

                            const SizedBox(height: 16),

                            // ⭕ CARD ORÇAMENTO DO MÊS COM GRÁFICO CIRCULAR
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1424).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.04)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("ORÇAMENTO MENSAL", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  const Text("Demonstrativo do Ciclo Ativo", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: CircularProgressIndicator(
                                            value: percentualConsumido,
                                            strokeWidth: 10,
                                            backgroundColor: Colors.white.withOpacity(0.05),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${(percentualConsumido * 100).toStringAsFixed(0)}%",
                                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const Text("UTILIZADO", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Limite de Saldo Disponível", style: TextStyle(color: Colors.white54, fontSize: 13)),
                                      Text(
                                        "R\$ ${restanteOrcamento.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      
      // 🕹️ NAV BAR INFERIOR CONECTADA AO CALLBACK CENTRAL
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
                _buildBottomActionItem(index: 0, icone: Icons.home_filled, label: "Início"),
                _buildBottomActionItem(index: 1, icone: Icons.history, label: "Histórico"),
                
                // 🔥 Botão Central leva para a tela de novos lançamentos operacionais (ex: aba index 2 ou 3 conforme sua arquitetura)
                GestureDetector(
                  onTap: () => widget.onSelectTab?.call(2), 
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
                
                _buildBottomActionItem(index: 3, icone: Icons.bar_chart_outlined, label: "Relatórios"),
                _buildBottomActionItem(index: 4, icone: Icons.settings_outlined, label: "Ajustes"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalFluxCard({required String titulo, required String valor, required Color corLinha, required IconData icone}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1424).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: corLinha.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icone, color: corLinha, size: 14),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(corLinha.withOpacity(0.8)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionItem({required int index, required IconData icone, required String label}) {
    final bool ativo = _currentBottomIndex == index;
    return GestureDetector(
      onTap: () => widget.onSelectTab?.call(index), // Redireciona a mudança de aba para a estrutura mãe
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