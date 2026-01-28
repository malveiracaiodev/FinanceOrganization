import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_drawer.dart'; // Drawer reutilizável
import 'fundo_cosmico.dart'; // Fundo cósmico animado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cadastroFeito = prefs.getBool('cadastroFeito') ?? false;

  runApp(FinanceApp(cadastroFeito: cadastroFeito));
}

class FinanceApp extends StatelessWidget {
  final bool cadastroFeito;
  const FinanceApp({super.key, required this.cadastroFeito});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Organization Mark I',
      theme: ThemeData.dark(),
      home: cadastroFeito ? const DashboardPage() : const HomePage(),
    );
  }
}

/// HomePage com menu, Mark I pulsante e logotipo
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bem-vindo ao Finance Organization",
                style: TextStyle(color: Colors.cyan, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                "Mark I",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
              const SizedBox(height: 40),
              Image.asset(
                "assets/meu_logotipo.png",
                height: 120,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SemiCadastroPage()),
                  );
                },
                child: const Text("Fazer Cadastro"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de semi-cadastro
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

/// Dashboard principal
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, dynamic>> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString('nome') ?? '',
      'sobrenome': prefs.getString('sobrenome') ?? '',
      'empresa': prefs.getString('empresa') ?? '',
      'cargo': prefs.getString('cargo') ?? '',
      'ganho': prefs.getDouble('ganho') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: FutureBuilder<Map<String, dynamic>>(
          future: carregarDados(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final dados = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Olá, ${dados['nome']} ${dados['sobrenome']}",
                    style: const TextStyle(color: Colors.cyan, fontSize: 22)),
                Text("${dados['cargo']} em ${dados['empresa']}",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 20),
                Text("Ganho Fixo: R\$ ${dados['ganho'].toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Colors.greenAccent, fontSize: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}
