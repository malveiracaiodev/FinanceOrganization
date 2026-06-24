import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../models/controle_financeiro.dart';
import '../../services/preferences_service.dart';
import '../../services/controle_service.dart';
import '../../services/parcelas_service.dart'; // 🔥 Conexão com o motor de parcelamentos
import '../../widgets/app_drawer.dart';
import '../../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Usuario? usuario;
  ControleFinanceiro? controle;
  double totalParcelasMes = 0;

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final user = await PreferencesService.carregarUsuario();
    final ctrl = await ControleService.carregarControle();
    // 🔥 Puxa o valor total das parcelas vigentes neste mês
    final parcelas = await ParcelasService.calcularTotalMes();

    if (!mounted) return;

    setState(() {
      usuario = user;
      controle = ctrl;
      totalParcelasMes = parcelas;
      carregando = false;
    });
  }

  String getStatusFinanceiro(double saldo) {
    if (usuario == null) return "";
    if (saldo >= usuario!.ganhoFixo * 0.2) {
      return "Sistemas Operando: Saúde excelente 🟢";
    } else if (saldo >= 0) {
      return "Sistemas Operando: Órbita estável 🟡";
    } else {
      return "Aviso Critico: Déficit na Órbita 🔴";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calcula o saldo descontando também a fatura de parcelas do mês atual
    final saldoReal = controle != null && usuario != null
        ? controle!.saldoFinal(usuario!.ganhoFixo, totalParcelasDoMes: totalParcelasMes)
        : 0.0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: carregando
            ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌌 Barra de Controle Superior (Abertura do Drawer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white60),
                            onPressed: () {
                              setState(() => carregando = true);
                              carregarDados();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "Olá, ${usuario!.nome}",
                        style: const TextStyle(
                          color: AstraTheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${usuario!.cargo} em ${usuario!.empresa}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        getStatusFinanceiro(saldoReal),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 💎 Painel Principal de Saldo (Estilo Glassmorphism do Astra)
                      _cardPrincipal(
                        titulo: "SALDO DINÂMICO REAL",
                        valor: saldoReal.toStringAsFixed(2),
                        cor: AstraTheme.secondary,
                      ),

                      const SizedBox(height: 16),

                      // 📊 Grid de Métricas Financeiras
                      Row(
                        children: [
                          Expanded(
                            child: _cardMini(
                              "Receitas Extras",
                              controle!.receitasExtras.toStringAsFixed(2),
                              Colors.greenAccent,
                              Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _cardMini(
                              "Despesas Diárias",
                              controle!.despesas.toStringAsFixed(2),
                              Colors.redAccent,
                              Icons.arrow_downward,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _cardMini(
                              "Despesas Previstas",
                              controle!.despesasPrevistas.toStringAsFixed(2),
                              Colors.orangeAccent,
                              Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _cardMini(
                              "Fatura de Parcelas",
                              totalParcelasMes.toStringAsFixed(2),
                              const Color(0xFFE040FB),
                              Icons.credit_card,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      const Center(
                        child: Text(
                          "SISTEMA FINANCEIRO MARK I",
                          style: TextStyle(
                            color: Colors.white12,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _cardPrincipal({
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "R\$ $valor",
            style: TextStyle(
              fontSize: 34,
              color: cor,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardMini(String titulo, String valor, Color cor, IconData icone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Icon(icone, color: cor.withOpacity(0.6), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "R\$ $valor",
            style: TextStyle(
              color: cor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}