import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';
import 'navegacao_page.dart'; // Hub centralizado de abas

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

  @override
  void dispose() {
    // 🔥 Liberação obrigatória de fluxo de memória (Previne Memory Leaks)
    nomeController.dispose();
    sobrenomeController.dispose();
    empresaController.dispose();
    cargoController.dispose();
    ganhoController.dispose();
    super.dispose();
  }

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

    // Redirecionamento limpo substituindo a pilha de navegação
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NavegacaoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B16),
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 40),
                
                const Center(
                  child: Icon(
                    Icons.analytics_rounded,
                    size: 64,
                    color: Color(0xFF00B4D8), // Unificado ao tom orbital do Stitch
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "FINANÇAS MARK I",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00B4D8),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Configuração de Conta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // 📝 Formulário Profissionalizado
                _campo("Nome do Usuário", nomeController, icon: Icons.person_outline_rounded),
                _campo("Sobrenome", sobrenomeController, icon: Icons.badge_outlined),
                _campo("Empresa / Organização", empresaController, icon: Icons.business_center_outlined),
                _campo("Cargo / Função", cargoController, icon: Icons.work_outline_rounded),

                _campo(
                  "Renda Mensal Base (Salário)",
                  ganhoController,
                  teclado: const TextInputType.numberWithOptions(decimal: true),
                  prefixo: "R\$ ",
                  icon: Icons.account_balance_wallet_outlined,
                  isMonetary: true,
                ),

                const SizedBox(height: 24),

                // 🚀 Botão Estilizado Neon integrado
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando ? null : salvarCadastro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: const Color(0xFF060B16),
                      disabledBackgroundColor: const Color(0xFF00B4D8).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: salvando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Color(0xFF060B16), strokeWidth: 3),
                          )
                        : const Text(
                            "INICIALIZAR SISTEMA",
                            style: TextStyle(letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.bold),
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
    bool isMonetary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        style: TextStyle(
          color: Colors.white, 
          fontSize: 15,
          fontFamily: isMonetary ? 'monospace' : null,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixo,
          prefixStyle: isMonetary ? const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold) : null,
          prefixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}