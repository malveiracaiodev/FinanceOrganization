import 'package:flutter/material.dart';

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
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final resUsuario = await PreferencesService.carregarUsuario();
      final resControle = await ControleService.carregarControle();

      if (!mounted) return;

      setState(() {
        usuario = resUsuario;
        controle = resControle;
        
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
    final theme = Theme.of(context);
    final totalEntradas = (usuario?.ganhoFixo ?? 0.0) + (controle?.receitasExtras ?? 0.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab),
      backgroundColor: Colors.transparent,
      body: FundoCosmico(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: carregando
              ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
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
                              icon: Icon(Icons.notes_rounded, color: theme.iconTheme.color ?? Colors.white, size: 28),
                              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            ),
                            Text(
                              "PAINEL GERENCIAL",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh_rounded, color: (theme.iconTheme.color ?? Colors.white).withOpacity(0.7), size: 24),
                              onPressed: carregarDados,
                            ),
                          ],
                        ),
                      ),

                      // 🌌 Área de Rolagem Dinâmica
                      Expanded(
                        child: RefreshIndicator(
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          onRefresh: carregarDados,
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
                                    color: theme.cardColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.03),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "SALDO ATUAL CONSOLIDADO",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: (theme.textTheme.bodySmall?.color ?? Colors.white).withOpacity(0.4),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "R\$ ${saldoReal.toStringAsFixed(2)}",
                                        style: theme.textTheme.displayLarge?.copyWith(
                                          color: theme.colorScheme.secondary,
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
                                          color: theme.colorScheme.primary.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Ambiente Operacional Seguro",
                                              style: TextStyle(
                                                color: theme.colorScheme.primary, 
                                                fontSize: 11, 
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                    color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, color: theme.colorScheme.secondary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Entradas acumuladas neste ciclo: R\$ ${totalEntradas.toStringAsFixed(2)}",
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: (theme.textTheme.bodyMedium?.color ?? Colors.white).withOpacity(0.6),
                                            fontSize: 13,
                                            fontFamily: 'monospace',
                                          ),
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
      ),
    );
  }
}