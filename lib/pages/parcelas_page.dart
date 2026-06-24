import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/parcela.dart';
import '../services/parcelas_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class ParcelasPage extends StatefulWidget {
  const ParcelasPage({super.key});

  @override
  State<ParcelasPage> createState() => _ParcelasPageState();
}

class _ParcelasPageState extends State<ParcelasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Parcela> parcelas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final dados = await ParcelasService.carregarParcelas();
    if (!mounted) return;
    setState(() {
      parcelas = dados;
      carregando = false;
    });
  }

  Future<void> excluir(String id) async {
    await ParcelasService.deletarParcelas(id); // Alinhado com o service interno
    await carregar();
  }

  Future<void> abrirFormulario() async {
    final descController = TextEditingController();
    final totalController = TextEditingController();
    final qtdController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1E),
        title: const Text(
          "NOVO AGENDAMENTO DE PARCELA",
          style: TextStyle(color: AstraTheme.secondary, fontSize: 13, letterSpacing: 1),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Descrição (Ex: Notebook)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Valor Total (R\$)",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            TextField(
              controller: qtdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Quantidade de Parcelas",
                labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("AGENDAR"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final vTotal = double.tryParse(totalController.text.replaceAll(',', '.')) ?? 0;
    final totalP = int.tryParse(qtdController.text) ?? 1;

    if (descController.text.isEmpty || vTotal <= 0) return;

    final nova = Parcela(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descricao: descController.text,
      valorTotal: vTotal,
      valorParcela: vTotal / totalP, // Calcula automaticamente o valor da parcela mensal
      totalParcelas: totalP,
      parcelaAtual: 1,
      ativa: true,
    );

    await ParcelasService.salvarParcelas(nova); // Alinhado com o seu service
    await carregar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AstraTheme.primary,
        onPressed: abrirFormulario,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FundoCosmico(
        child: SafeArea(
          child: carregando
              ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de controle superior
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const Text(
                            "CRONOGRAMA DE PARCELAS",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Lista Operacional de Parcelados
                      Expanded(
                        child: parcelas.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nenhum parcelamento ativo no radar.",
                                  style: TextStyle(color: Colors.white38),
                                ),
                              )
                            : ListView.builder(
                                itemCount: parcelas.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final p = parcelas[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.descricao,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            "R\$ ${p.valorParcela.toStringAsFixed(2)}/mês",
                                            style: const TextStyle(color: AstraTheme.secondary, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          "Total: R\$ ${p.valorTotal.toStringAsFixed(2)} | Progresso: ${p.parcelaAtual}x de ${p.totalParcelas}x",
                                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 24),
                                        onPressed: () => excluir(p.id),
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
      ),
    );
  }
}