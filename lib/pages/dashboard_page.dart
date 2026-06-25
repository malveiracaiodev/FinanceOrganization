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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final resUsuario = await PreferencesService.carregarUsuario();
      final resControle = await ControleService.carregarControle();

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
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Soma correta de Entradas protegendo contra nulos
    final totalEntradas = (usuario?.ganhoFixo ?? 0.0) + (controle?.receitasExtras ?? 0.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab),
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
                            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white70, size: 24), // 🔥 Corrigido parâmetro 'icon:' e cor 'white70'
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
                                color: const Color(0xFF0B1424).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AstraTheme.primary.withValues(alpha: 0.15)),
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
                                      color: AstraTheme.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shield_outlined, color: AstraTheme.primary, size: 14), // 🔥 Corrigido nome do ícone
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
                            
                            // Espaço extra para futuras seções (Ex: receitas, despesas previstas, etc)
                            const SizedBox(height: 20),
                            Text(
                              "Entradas acumuladas neste ciclo: R\$ ${totalEntradas.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}