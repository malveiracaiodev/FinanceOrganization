import 'package:flutter/material.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../models/parcela.dart'; 
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../services/parcelas_service.dart'; 
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
  List<Parcela> parcelasAtivas = []; 
  double parcelamentoTotalAcumulado = 0.0; 

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final resUsuario = await PreferencesService.carregarUsuario();
      final resControle = await ControleService.carregarControle();
      final resParcelas = await ParcelasService.carregarParcelas(); 

      double totalMes = 0.0;
      final ativas = resParcelas.where((p) => p.ativa).toList();
      for (var p in ativas) {
        totalMes += p.valorParcela;
      }

      if (!mounted) return;

      setState(() {
        usuario = resUsuario;
        controle = resControle;
        parcelasAtivas = ativas;
        parcelamentoTotalAcumulado = totalMes;
        carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar Dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const corRoxoParcelamento = Colors.purpleAccent;
    const corTextoAlta = Colors.white;

    return Scaffold(
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    // 💳 Card de Saldo e Parcelamento
                    Card(
                      color: Colors.black54,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text("SALDO DISPONÍVEL", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              "R\$ ${(usuario?.saldoAtual ?? 0.0).toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: corTextoAlta),
                            ),
                            const Divider(color: Colors.white24),
                            const Text("TOTAL PARCELAMENTO", style: TextStyle(fontSize: 10, color: corRoxoParcelamento)),
                            Text(
                              "R\$ ${parcelamentoTotalAcumulado.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: corRoxoParcelamento),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de Parcelas Ativas
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Parcelas Ativas (${parcelasAtivas.length})", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    
                    Column(
                      children: [
                        ...parcelasAtivas.map(
                          (p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${p.descricao} (${p.parcelaAtual}/${p.totalParcelas})",
                                  style: const TextStyle(color: corTextoAlta, fontSize: 13),
                                ),
                                Text(
                                  "R\$ ${p.valorParcela.toStringAsFixed(2)}",
                                  style: const TextStyle(color: corRoxoParcelamento, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}