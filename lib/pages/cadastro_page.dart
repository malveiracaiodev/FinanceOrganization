import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';
import 'navegacao_page.dart'; // 🔥 Ajustado para o hub centralizado de abas

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
        const SnackBar(content: Text("Por favor, preencha o nome e sobrenome do usuário.")),
      );
      return;
    }

    final ganho = double.tryParse(
      ganhoController.text.replaceAll(',', '.'),
    );

    if (ganho == null || ganho < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe uma renda mensal base válida.")),
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
      saldoAtual: ganho, // Mapeamento inicial equilibrado
      ultimoMesVerificado: DateTime.now().month,
    );

    await PreferencesService.salvarUsuario(usuario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil financeiro configurado com sucesso!")),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 🔥 Correção crucial de rota: Entra no hub com a barra de navegação ativa
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NavegacaoPage()),
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
                
                Center(
                  child: Icon(
                    Icons.analytics_outlined, // Ícone mais corporativo/financeiro
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
                  "Configuração de Conta",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 30),

                // 📝 Formulário Profissionalizado
                _campo("Nome do Usuário", nomeController, icon: Icons.person_outline),
                _campo("Sobrenome", sobrenomeController, icon: Icons.badge_outlined),
                _campo("Empresa / Organização", empresaController, icon: Icons.business_outlined),
                _campo("Cargo / Função", cargoController, icon: Icons.work_outline),

                _campo(
                  "Renda Mensal Base (Salário)",
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
          prefixText: prefixo,
          prefixIcon: Icon(icon, size: 20),
          // Herda inteligentemente as bordas e preenchimento que calibramos no AstraTheme!
        ),
      ),
    );
  }
}