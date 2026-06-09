import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';
import 'dashboard_page.dart';

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

  bool salvando = false;

  Future<void> salvarCadastro() async {
    if (nomeController.text.trim().isEmpty ||
        sobrenomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha nome e sobrenome")),
      );
      return;
    }

    final ganho = double.tryParse(
      ganhoController.text.replaceAll(',', '.'),
    );

    if (ganho == null || ganho < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um salário válido")),
      );
      return;
    }

    setState(() => salvando = true);

    final usuario = Usuario(
      nome: nomeController.text.trim(),
      sobrenome: sobrenomeController.text.trim(),
      empresa: empresaController.text.trim(),
      cargo: cargoController.text.trim(),
      ganhoFixo: ganho,
    );

    await PreferencesService.salvarUsuario(usuario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cadastro realizado com sucesso!")),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 40),

              const Text(
                "Bem-vindo ao FinanceControl",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.cyan, fontSize: 22),
              ),

              const SizedBox(height: 30),

              _campo("Nome", nomeController),
              _campo("Sobrenome", sobrenomeController),
              _campo("Empresa", empresaController),
              _campo("Cargo", cargoController),

              _campo(
                "Ganho Fixo",
                ganhoController,
                teclado: TextInputType.number,
                prefixo: "R\$ ",
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: salvando ? null : salvarCadastro,
                child: salvando
                    ? const CircularProgressIndicator()
                    : const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    TextInputType teclado = TextInputType.text,
    String? prefixo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixo,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}