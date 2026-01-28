import 'package:flutter/material.dart';
import 'fundo_cosmico.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlePage extends StatefulWidget {
  const ControlePage({super.key});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  final ganhoController = TextEditingController();
  final gastoController = TextEditingController();
  final gastoPrevistoController = TextEditingController();

  double totalGanhos = 0;
  double totalGastos = 0;
  double totalPrevistos = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalGanhos = prefs.getDouble('totalGanhos') ?? 0;
      totalGastos = prefs.getDouble('totalGastos') ?? 0;
      totalPrevistos = prefs.getDouble('totalPrevistos') ?? 0;
    });
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalGanhos', totalGanhos);
    await prefs.setDouble('totalGastos', totalGastos);
    await prefs.setDouble('totalPrevistos', totalPrevistos);
  }

  Future<void> adicionarGanho() async {
    final valor = double.tryParse(ganhoController.text) ?? 0;
    setState(() {
      totalGanhos += valor;
    });
    ganhoController.clear();
    salvarDados();
  }

  Future<void> adicionarGasto() async {
    final valor = double.tryParse(gastoController.text) ?? 0;
    setState(() {
      totalGastos += valor;
    });
    gastoController.clear();
    salvarDados();
  }

  Future<void> adicionarPrevisto() async {
    final valor = double.tryParse(gastoPrevistoController.text) ?? 0;
    setState(() {
      totalPrevistos += valor;
    });
    gastoPrevistoController.clear();
    salvarDados();
  }

  Future<void> encerrarMes() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Encerrar mês"),
        content: const Text("Tem certeza que deseja finalizar o mês?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (!mounted) return; // garante que o widget ainda existe

    if (confirmar == true) {
      setState(() {
        totalGanhos = 0;
        totalGastos = 0;
        totalPrevistos = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mês encerrado com sucesso!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                "Controle Financeiro",
                style: TextStyle(color: Colors.cyan, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ganhoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Adicionar Ganho",
                  prefixText: "R\$ ",
                ),
              ),
              ElevatedButton(
                onPressed: adicionarGanho,
                child: const Text("Adicionar Ganho"),
              ),
              TextField(
                controller: gastoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Adicionar Gasto",
                  prefixText: "R\$ ",
                ),
              ),
              ElevatedButton(
                onPressed: adicionarGasto,
                child: const Text("Adicionar Gasto"),
              ),
              TextField(
                controller: gastoPrevistoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Adicionar Gasto Previsto",
                  prefixText: "R\$ ",
                ),
              ),
              ElevatedButton(
                onPressed: adicionarPrevisto,
                child: const Text("Adicionar Previsto"),
              ),
              const SizedBox(height: 30),
              Text("Total de Ganhos: R\$ ${totalGanhos.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.greenAccent)),
              Text("Total de Gastos: R\$ ${totalGastos.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.redAccent)),
              Text(
                  "Total de Previstos: R\$ ${totalPrevistos.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.orangeAccent)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: encerrarMes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text("Encerrar Mês"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
