import 'package:flutter/material.dart';
import '../models/historico_mensal.dart';
import '../services/historico_service.dart';
import '../widgets/fundo_cosmico.dart';

class HistoricoPage extends StatefulWidget {
  final Function(int)? onSelectTab;

  const HistoricoPage({super.key, this.onSelectTab});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<HistoricoMensal> historico = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await HistoricoService.carregar();
    if (!mounted) return;
    setState(() {
      historico = data;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
              : historico.isEmpty
                  ? const Center(child: Text("Nenhum ciclo fechado no histórico.", style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      itemCount: historico.length,
                      itemBuilder: (context, index) {
                        final mes = historico[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1128),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("PERÍODO: ${mes.mesAno}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    mes.resto >= 0 ? "SUPERÁVIT" : "DÉFICIT",
                                    style: TextStyle(color: mes.resto >= 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: Colors.white10),
                              Text(
                                "Fixo: R\$ ${mes.ganhoFixo.toStringAsFixed(2)}\n"
                                "Extras: R\$ ${mes.ganhosAdicionais.toStringAsFixed(2)}\n"
                                "Gastos Totais: R\$ ${mes.gastosTotais.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mes.statusOrbital,
                                style: TextStyle(color: const Color(0xFF00B4D8).withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}