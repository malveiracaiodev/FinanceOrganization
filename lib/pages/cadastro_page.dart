import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para os formatadores de texto

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
  // Chave global do formulário para controle de validação nativa
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final ganhoController = TextEditingController();

  bool salvando = false;

  @override
  void dispose() {
    // Liberação obrigatória de fluxo de memória (Previne Memory Leaks)
    nomeController.dispose();
    sobrenomeController.dispose();
    empresaController.dispose();
    cargoController.dispose();
    ganhoController.dispose();
    super.dispose();
  }

  Future<void> salvarCadastro() async {
    // Executa a validação visual do formulário. Se falhar, interrompe aqui.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Injeção de estado de carregamento
    setState(() => salvando = true);

    try {
      final nomeText = nomeController.text.trim();
      final sobrenomeText = sobrenomeController.text.trim();
      
      // Conversão segura garantida pela validação e pelo formatador de texto
      final ganho = double.parse(
        ganhoController.text.replaceAll(',', '.'),
      );

      // Instanciação do modelo de Usuário
      final usuario = Usuario(
        nome: nomeText,
        sobrenome: sobrenomeText, 
        empresa: empresaController.text.trim(),
        cargo: cargoController.text.trim(),
        ganhoFixo: ganho,
        saldoAtual: ganho, 
        ultimoMesVerificado: DateTime.now().month,
      );

      // Gravação local
      await PreferencesService.salvarUsuario(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil financeiro configurado com sucesso!")),
      );

      // Breve pausa para o usuário ler o feedback de sucesso
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Redirecionamento com animação Fade elegante
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const NavegacaoPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      debugPrint("Erro ao salvar cadastro: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro crítico ao salvar as configurações. Tente novamente.")),
      );
    } finally {
      // Garante que o estado de carregamento seja redefinido caso ocorra algum erro
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Integrado ao fundo do seu tema
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey, // Envolvemos todo o corpo em um Form
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 40),
                  
                  Center(
                    child: Icon(
                      Icons.analytics_rounded,
                      size: 64,
                      color: theme.primaryColor, // Cores do tema global
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "FINANÇAS MARK I",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Configuração de Conta",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 📝 Formulário com Validadores Integrados
                  _campo(
                    "Nome do Usuário", 
                    nomeController, 
                    icon: Icons.person_outline_rounded,
                    validator: (val) => val == null || val.trim().isEmpty ? "Informe o seu primeiro nome" : null,
                  ),
                  _campo(
                    "Sobrenome", 
                    sobrenomeController, 
                    icon: Icons.badge_outlined,
                    validator: (val) => val == null || val.trim().isEmpty ? "Informe o seu sobrenome" : null,
                  ),
                  _campo(
                    "Empresa / Organização", 
                    empresaController, 
                    icon: Icons.business_center_outlined,
                    // Campo opcional (sem validator)
                  ),
                  _campo(
                    "Cargo / Função", 
                    cargoController, 
                    icon: Icons.work_outline_rounded,
                    // Campo opcional (sem validator)
                  ),
                  _campo(
                    "Renda Mensal Base (Salário)",
                    ganhoController,
                    teclado: const TextInputType.numberWithOptions(decimal: true),
                    prefixo: "R\$ ",
                    icon: Icons.account_balance_wallet_outlined,
                    isMonetary: true,
                    // Filtra o input para permitir apenas números, pontos e vírgulas
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Informe sua renda mensal base";
                      }
                      final valor = double.tryParse(val.replaceAll(',', '.'));
                      if (valor == null || valor < 0) {
                        return "Insira um valor numérico válido";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // 🚀 Botão Principal Adaptado
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: salvando ? null : salvarCadastro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: theme.primaryColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: salvando
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
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
      ),
    );
  }

  // Componente de Campo de Entrada Refatorado para TextFormField
  Widget _campo(
    String label,
    TextEditingController controller, {
    TextInputType teclado = TextInputType.text,
    String? prefixo,
    required IconData icon,
    bool isMonetary = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        validator: validator,
        inputFormatters: formatters,
        style: TextStyle(
          color: Colors.white, 
          fontSize: 15,
          fontFamily: isMonetary ? 'monospace' : null,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixo,
          prefixStyle: isMonetary ? TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold) : null,
          prefixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}