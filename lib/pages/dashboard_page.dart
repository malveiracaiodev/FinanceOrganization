import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../models/controle_financeiro.dart';
import '../../services/preferences_service.dart';
import '../../services/controle_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Usuario? usuario;
  ControleFinanceiro? controle;

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final user = await PreferencesService.carregarUsuario();
    final ctrl = await ControleService.carregarControle();

    if (!mounted) return;

    setState(() {
      usuario = user;
      controle = ctrl;
      carregando = false;
    });
  }

  String getStatusFinanceiro(double saldo) {
    if (saldo >= usuario!.ganhoFixo * 0.2) {
      return "Saúde financeira excelente 🟢";
    } else if (saldo >= 0) {
      return "Saúde financeira estável 🟡";
    } else {
      return "Atenção: déficit financeiro 🔴";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Olá, ${usuario!.nome}",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${usuario!.cargo} em ${usuario!.empresa}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        getStatusFinanceiro(
                          controle!.saldoFinal(usuario!.ganhoFixo),
                        ),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 25),

                      _cardPrincipal(
                        titulo: "Saldo Atual",
                        valor: controle!
                            .saldoFinal(usuario!.ganhoFixo)
                            .toStringAsFixed(2),
                        cor: AppTheme.secondaryColor,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _cardMini(
                              "Receitas",
                              controle!.receitasExtras.toStringAsFixed(2),
                              Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _cardMini(
                              "Despesas",
                              controle!.despesas.toStringAsFixed(2),
                              Colors.redAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _cardMini(
                              "Previsto",
                              controle!.despesasPrevistas.toStringAsFixed(2),
                              Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _cardMini(
                              "Base",
                              usuario!.ganhoFixo.toStringAsFixed(2),
                              Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Center(
                        child: Text(
                          "FinanceControl Mark I",
                          style: TextStyle(
                            color: Colors.white24,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(titulo),
            const SizedBox(height: 10),
            Text(
              "R\$ $valor",
              style: TextStyle(
                fontSize: 32,
                color: cor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardMini(String titulo, String valor, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(titulo),
            const SizedBox(height: 5),
            Text(
              "R\$ $valor",
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}