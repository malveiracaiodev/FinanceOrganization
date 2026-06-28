import 'package:flutter/material.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onSelectTab;

  const DashboardPage({super.key, this.onSelectTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
      await Future.delayed(const Duration(milliseconds: 100));

      final resUsuario = await PreferencesService.carregarUsuario();
      final resControle = await ControleService.carregarControle();

      if (!mounted) return;

      setState(() {
  usuario = resUsuario;
  controle = resControle;
  
  final ganhoFixo = resUsuario?.ganhoFixo ?? 0.0;
  // ✨ CORREÇÃO DA LINHA 44: Como resControle nunca é nulo, chamamos o método diretamente de forma limpa
  saldoReal = resControle.saldoFinal(ganhoFixo);
  
  carregando = false;
});
    } catch (e) {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color corBorda = Color(0xFF00B4D8);
    const Color corTextoAlta = Colors.white;
    const Color corTextoMedia = Colors.white70;

    final totalEntradas = (usuario?.ganhoFixo ?? 0.0) + (controle?.receitasExtras ?? 0.0);
    final totalSaidas = controle?.despesas ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: corBorda))
            : RefreshIndicator(
                onRefresh: carregarDados,
                backgroundColor: const Color(0xFF0A1128),
                color: corBorda,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Boas-vindas
                      Text(
                        "BEM-VINDO, COMANDANTE",
                        style: TextStyle(
                          color: corBorda.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario?.nomeCompleto.toUpperCase() ?? "PILOTO DA MARK I",
                        style: const TextStyle(
                          color: corTextoAlta,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card de Saldo
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: corBorda.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SALDO EM CARTEIRA ORBITAL",
                              style: TextStyle(color: corTextoMedia, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "R\$ ${saldoReal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: corBorda,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Património Líquido Atualizado",
                              style: TextStyle(color: corTextoMedia.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Atalhos Rápidos
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onSelectTab?.call(1),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: const Text("FLUXO"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1128),
                                foregroundColor: corBorda,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  // 🛡️ CORREÇÃO LN 150: Modificado de Border.all para BorderSide genuíno
                                  side: BorderSide(color: corBorda.withValues(alpha: 0.15)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => widget.onSelectTab?.call(2),
                              icon: const Icon(Icons.credit_card_rounded, size: 18),
                              label: const Text("CARTÕES"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1128),
                                foregroundColor: corBorda,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  // 🛡️ CORREÇÃO LN 167: Modificado de Border.all para BorderSide genuíno
                                  side: BorderSide(color: corBorda.withValues(alpha: 0.15)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Painel de Métricas do Mês
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070D19),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "MÉTRICAS DO CICLO CORRENTE",
                              style: TextStyle(color: corTextoAlta, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("ENTRADAS ACUMULADAS", style: TextStyle(color: corTextoMedia, fontSize: 10)),
                                    Text("R\$ ${totalEntradas.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  ],
                                )
                              ],
                            ),
                            const Divider(height: 24, color: Colors.white10),
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward_rounded, color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("SAÍDAS REGISTADAS", style: TextStyle(color: corTextoMedia, fontSize: 10)),
                                    Text("R\$ ${totalSaidas.toStringAsFixed(2)}", style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  ],
                                )
                              ],
                            ),
                            const Divider(height: 24, color: Colors.white10),
                            Row(
                              children: [
                                const Icon(Icons.analytics_outlined, color: Colors.orangeAccent),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("PREVISTO ADICIONAL", style: TextStyle(color: corTextoMedia, fontSize: 10)),
                                    Text("R\$ ${(controle?.despesasPrevistas ?? 0.0).toStringAsFixed(2)}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  ],
                                )
                              ],
                            ),
                          ],
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