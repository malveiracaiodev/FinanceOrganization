import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa o Drawer centralizado
import 'app_drawer.dart';
// Importa o Fundocosmico
import 'fundo_cosmico.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final ganhoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return; // garante que o widget ainda existe

    setState(() {
      nomeController.text = prefs.getString('nome') ?? '';
      sobrenomeController.text = prefs.getString('sobrenome') ?? '';
      empresaController.text = prefs.getString('empresa') ?? '';
      cargoController.text = prefs.getString('cargo') ?? '';
      ganhoController.text = (prefs.getDouble('ganho') ?? 0).toString();
    });
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', nomeController.text);
    await prefs.setString('sobrenome', sobrenomeController.text);
    await prefs.setString('empresa', empresaController.text);
    await prefs.setString('cargo', cargoController.text);
    await prefs.setDouble('ganho', double.tryParse(ganhoController.text) ?? 0);

    if (!mounted) return; // evita usar context se desmontado

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados atualizados com sucesso!")),
    );
  }

  Future<void> limparControle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ganho', 0);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Dados da página de controle foram limpos!")),
    );
  }

  Future<void> limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historico'); // placeholder

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Histórico foi apagado!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // puxando o Drawer reutilizável
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                "Configurações Pessoais",
                style: TextStyle(color: Colors.cyan, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Campos de edição
              _campoEdicao("Nome", nomeController),
              _campoEdicao("Sobrenome", sobrenomeController),
              _campoEdicao("Empresa", empresaController),
              _campoEdicao("Cargo", cargoController),
              _campoEdicao("Ganho Fixo (R\$)", ganhoController),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: salvarDados,
                child: const Text("Salvar Alterações"),
              ),
              const SizedBox(height: 20),

              // Botões extras
              ElevatedButton(
                onPressed: limparControle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Limpar Página de Controle"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: limparHistorico,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Apagar Histórico / Mês"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoEdicao(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.cyan),
          onPressed: () {
            // foco no campo para edição
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
      ],
    );
  }
}
