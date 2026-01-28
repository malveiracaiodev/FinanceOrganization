import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart'; // separa Dashboard em arquivo próprio
import 'fundo_cosmico.dart'; // fundo cósmico padronizado

class SemiCadastroPage extends StatefulWidget {
  const SemiCadastroPage({super.key});

  @override
  State<SemiCadastroPage> createState() => _SemiCadastroPageState();
}

class _SemiCadastroPageState extends State<SemiCadastroPage> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final ganhoController = TextEditingController();

  Future<void> salvarCadastro() async {
    if (nomeController.text.isEmpty || sobrenomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha nome e sobrenome")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', nomeController.text);
    await prefs.setString('sobrenome', sobrenomeController.text);
    await prefs.setString('empresa', empresaController.text);
    await prefs.setString('cargo', cargoController.text);
    await prefs.setDouble('ganho', double.tryParse(ganhoController.text) ?? 0);
    await prefs.setBool('cadastroFeito', true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cadastro realizado com sucesso!")),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    });
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
                "Bem-vindo! Faça seu cadastro inicial",
                style: TextStyle(color: Colors.cyan, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome")),
              TextField(
                  controller: sobrenomeController,
                  decoration: const InputDecoration(labelText: "Sobrenome")),
              TextField(
                  controller: empresaController,
                  decoration: const InputDecoration(labelText: "Empresa")),
              TextField(
                  controller: cargoController,
                  decoration: const InputDecoration(labelText: "Cargo")),
              TextField(
                controller: ganhoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Ganho Fixo", prefixText: "R\$ "),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: salvarCadastro, child: const Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
