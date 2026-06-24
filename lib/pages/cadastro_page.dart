import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';
import 'dashboard_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
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
        const SnackBar(content: Text("Por favor, preencha nome e sobrenome do Comandante.")),
      );
      return;
    }

    final ganho = double.tryParse(
      ganhoController.text.replaceAll(',', '.'),
    );

    if (ganho == null || ganho < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um ganho mensal base válido.")),
      );
      return;
    }

    setState(() => salvando = true);

    // 🔥 Integração com o novo construtor da Model Usuario
    final usuario = Usuario(
      nome: nomeController.text.trim(),
      sobrenome: sobrenomeController.text.trim(),
      empresa: empresaController.text.trim(),
      cargo: cargoController.text.trim(),
      ganhoFixo: ganho,
      saldoAtual: ganho, // Mapeamento inicial: Seu primeiro saldo é seu ganho base
      ultimoMesVerificado: DateTime.now().month, // Registra o mês de entrada do sistema
    );

    await PreferencesService.salvarUsuario(usuario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sistemas Mark I inicializados com sucesso!")),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 30),
                
                // 🌌 Cabeçalho Estilizado Stitch
                Center(
                  child: Icon(
                    Icons.rocket_launch,
                    size: 60,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "FINANÇAS MARK I",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00D4FF),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Alistamento de Tripulação",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 30),

                // 📝 Formulário Espacial
                _campo("Nome do Comandante", nomeController, icon: Icons.person_outline),
                _campo("Sobrenome", sobrenomeController, icon: Icons.badge_outlined),
                _campo("Frota / Empresa", empresaController, icon: Icons.business_outlined),
                _campo("Posto / Cargo", cargoController, icon: Icons.work_outline),

                _campo(
                  "Créditos Mensais Base (Salário)",
                  ganhoController,
                  teclado: TextInputType.number,
                  prefixo: "R\$ ",
                  icon: Icons.account_balance_wallet_outlined,
                ),

                const SizedBox(height: 24),

                // 🚀 Botão Estilizado Neon
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando ? null : salvarCadastro,
                    child: salvando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                          )
                        : const Text(
                            "INICIALIZAR SISTEMA",
                            style: TextStyle(letterSpacing: 1.5, fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
          prefixText: prefixo,
          prefixStyle: const TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.02),
          // Customização de bordas futuristas baseadas no seu AstraTheme
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1.5),
          ),
        ),
      ),
    );
  }
}