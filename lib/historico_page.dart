import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'app_drawer.dart';
import 'fundo_cosmico.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<Map<String, dynamic>> historico = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  /// Carrega o histórico salvo em SharedPreferences
  Future<void> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final historicoSalvo = prefs.getStringList('historicoMensal') ?? [];

    setState(() {
      historico = historicoSalvo
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  /// Salva o histórico atualizado
  Future<void> salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'historicoMensal',
      historico.map((e) => jsonEncode(e)).toList(),
    );
  }

  /// Função para editar um mês específico
  void editarMes(int index) {
    final item = historico[index];

    final ganhoController =
        TextEditingController(text: item['ganhoFixo'].toString());
    final adicionaisController =
        TextEditingController(text: item['ganhosAdicionais'].toString());
    final gastosController =
        TextEditingController(text: item['gastosTotais'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar ${item['mesAno']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ganhoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ganho Fixo"),
            ),
            TextField(
              controller: adicionaisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ganhos Adicionais"),
            ),
            TextField(
              controller: gastosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Gastos Totais"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['ganhoFixo'] =
                    double.tryParse(ganhoController.text) ?? item['ganhoFixo'];
                item['ganhosAdicionais'] =
                    double.tryParse(adicionaisController.text) ??
                        item['ganhosAdicionais'];
                item['gastosTotais'] = double.tryParse(gastosController.text) ??
                    item['gastosTotais'];
                item['resto'] = item['ganhoFixo'] +
                    item['ganhosAdicionais'] -
                    item['gastosTotais'];
              });
              salvarHistorico();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mês atualizado com sucesso!")),
              );
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Histórico Mensal",
                style: TextStyle(color: Colors.cyan, fontSize: 22),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: historico.length,
                  itemBuilder: (context, index) {
                    final mes = historico[index];
                    final cor = mes['resto'] >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent;
                    return Card(
                      color: Colors.black54,
                      child: ListTile(
                        title: Text(
                          "${mes['mesAno']} - Resto: R\$ ${mes['resto'].toStringAsFixed(2)}",
                          style: TextStyle(
                              color: cor, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Ganho Fixo: R\$ ${mes['ganhoFixo']} | "
                          "Ganhos Adicionais: R\$ ${mes['ganhosAdicionais']} | "
                          "Gastos Totais: R\$ ${mes['gastosTotais']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => editarMes(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
