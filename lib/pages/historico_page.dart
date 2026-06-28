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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
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
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
            : historico.isEmpty
                ? const Center(child: Text("Nenhuma missão registrada no histórico.", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      return _buildCardMes(historico[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildCardMes(HistoricoMensal item) {
    return Card(
      color: const Color(0xFF0A1128),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        iconColor: Colors.cyan,
        title: Text(item.mesAno, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(item.statusOrbital, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLinhaDetalhe("Receita Total", "R\$ ${item.receitaTotal.toStringAsFixed(2)}", Colors.white),
                _buildLinhaDetalhe("Gastos", "R\$ ${item.gastosTotais.toStringAsFixed(2)}", Colors.redAccent),
                const Divider(color: Colors.white10),
                _buildLinhaDetalhe("Saldo Final", "R\$ ${item.resto.toStringAsFixed(2)}", Colors.greenAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaDetalhe(String label, String valor, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(valor, style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}