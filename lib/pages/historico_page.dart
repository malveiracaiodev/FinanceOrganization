import 'package:flutter/material.dart';

import '../../models/historico_mensal.dart';
import '../../services/historico_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/fundo_cosmico.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

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

  Future<void> editarMes(int index) async {
    final item = historico[index];

    final ganhoController =
        TextEditingController(text: item.ganhoFixo.toString());
    final adicionaisController =
        TextEditingController(text: item.ganhosAdicionais.toString());
    final gastosController =
        TextEditingController(text: item.gastosTotais.toString());

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar ${item.mesAno}"),
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
              decoration:
                  const InputDecoration(labelText: "Ganhos Adicionais"),
            ),
            TextField(
              controller: gastosController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Gastos Totais"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final atualizado = HistoricoMensal(
      mesAno: item.mesAno,
      ganhoFixo: double.tryParse(ganhoController.text) ?? item.ganhoFixo,
      ganhosAdicionais:
          double.tryParse(adicionaisController.text) ??
              item.ganhosAdicionais,
      gastosTotais:
          double.tryParse(gastosController.text) ?? item.gastosTotais,
    );

    await HistoricoService.atualizarMes(index, atualizado);

    await carregar();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mês atualizado com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Histórico Mensal",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: historico.isEmpty
                        ? const Center(
                            child: Text(
                              "Nenhum histórico ainda",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: historico.length,
                            itemBuilder: (context, index) {
                              final mes = historico[index];

                              final cor = mes.resto >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent;

                              return Card(
                                color: Colors.black54,
                                child: ListTile(
                                  title: Text(
                                    "${mes.mesAno} - R\$ ${mes.resto.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: cor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Fixo: R\$ ${mes.ganhoFixo} | "
                                    "Extras: R\$ ${mes.ganhosAdicionais} | "
                                    "Gastos: R\$ ${mes.gastosTotais}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
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
    );
  }
}