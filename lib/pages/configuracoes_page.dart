import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../widgets/fundo_cosmico.dart';
import 'cadastro_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final empresaController = TextEditingController();
  final cargoController = TextEditingController();
  final ganhoController = TextEditingController();

  Usuario? usuarioOriginal;
  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    empresaController.dispose();
    cargoController.dispose();
    ganhoController.dispose();
    super.dispose();
  }

  // Carrega os dados existentes do perfil local
  Future<void> _carregarDados() async {
    final usuario = await PreferencesService.carregarUsuario();
    if (!mounted) return;

    if (usuario != null) {
      setState(() {
        usuarioOriginal = usuario;
        nomeController.text = usuario.nome;
        sobrenomeController.text = usuario.sobrenome;
        empresaController.text = usuario.empresa;
        cargoController.text = usuario.cargo;
        ganhoController.text = usuario.ganhoFixo.toStringAsFixed(2).replaceAll('.', ',');
        carregando = false;
      });
    } else {
      setState(() => carregando = false);
    }
  }

  // Salva as alterações preservando variáveis de progresso (Saldo e Mês Verificado)
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate() || usuarioOriginal == null) {
      return;
    }

    setState(() => salvando = true);

    try {
      final novoGanho = double.parse(ganhoController.text.replaceAll(',', '.'));

      // Cria a cópia atualizada do usuário preservando o saldo atual e o mês do ciclo
      final usuarioAtualizado = usuarioOriginal!.copyWith(
        nome: nomeController.text.trim(),
        sobrenome: sobrenomeController.text.trim(),
        empresa: empresaController.text.trim(),
        cargo: cargoController.text.trim(),
        ganhoFixo: novoGanho,
      );

      await PreferencesService.salvarUsuario(usuarioAtualizado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AstraTheme.successColor,
          content: Text("Configurações salvas com sucesso!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );

      // Atualiza o estado original para as próximas edições
      setState(() {
        usuarioOriginal = usuarioAtualizado;
      });
    } catch (e) {
      debugPrint("Erro ao salvar alterações do perfil: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar alterações.")),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  // Executa o reset completo e redireciona para a tela de cadastro
  Future<void> _executarResetDeFabrica() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AstraTheme.dangerColor),
            SizedBox(width: 8),
            Text("Reset de Fábrica"),
          ],
        ),
        content: const Text(
          "Atenção, Comandante! Esta ação apagará permanentemente todos os seus dados de perfil, histórico mensal, faturas e controle diário de fluxo. Deseja prosseguir?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AstraTheme.dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirmar Reset", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => salvando = true);
      
      // Executa a faxina física de chaves locais e de memória (Cache) que aprimoramos
      await PreferencesService.resetarAplicativo();

      if (!mounted) return;

      // Redireciona com efeito suave de esmaecimento para o cadastro de conta limpo
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CadastroPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false, // Limpa toda a pilha de navegação existente
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("CONFIGURAÇÕES"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: AstraTheme.primary))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 16),

                        // --- SEÇÃO 1: INFORMAÇÕES PESSOAIS ---
                        _buildSecaoTitulo(theme, "DADOS DO COMANDANTE"),
                        const SizedBox(height: 16),
                        _campo("Nome", nomeController, icon: Icons.person_outline_rounded),
                        _campo("Sobrenome", sobrenomeController, icon: Icons.badge_outlined),
                        _campo("Empresa / Organização", empresaController, icon: Icons.business_center_outlined),
                        _campo("Cargo / Função", cargoController, icon: Icons.work_outline_rounded),

                        const SizedBox(height: 24),

                        // --- SEÇÃO 2: PARÂMETROS FINANCEIROS ---
                        _buildSecaoTitulo(theme, "PARÂMETROS FINANCEIROS"),
                        const SizedBox(height: 16),
                        _campo(
                          "Renda Mensal Base (Salário)",
                          ganhoController,
                          teclado: const TextInputType.numberWithOptions(decimal: true),
                          prefixo: "R\$ ",
                          icon: Icons.account_balance_wallet_outlined,
                          isMonetary: true,
                          formatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Informe o salário";
                            final d = double.tryParse(val.replaceAll(',', '.'));
                            if (d == null || d < 0) return "Valor inválido";
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Botão de Gravar Alterações
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: salvando ? null : _salvarAlteracoes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.black,
                            ),
                            child: salvando
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                                  )
                                : const Text("SALVAR ALTERAÇÕES"),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // --- SEÇÃO 3: SISTEMA DE EMERGÊNCIA (RESET) ---
                        _buildSecaoTitulo(theme, "SISTEMA DE EMERGÊNCIA", cor: AstraTheme.dangerColor),
                        const SizedBox(height: 16),
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Esta ação é irreversível e apagará todas as tabelas locais de dados, restaurando o aplicativo para o estado original de instalação.",
                                  style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AstraTheme.dangerColor,
                                      side: const BorderSide(color: AstraTheme.dangerColor, width: 1.5),
                                    ),
                                    onPressed: salvando ? null : _executarResetDeFabrica,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_forever_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text("RESET DE FÁBRICA"),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

  // Divisor visual das seções de configurações
  Widget _buildSecaoTitulo(ThemeData theme, String titulo, {Color? cor}) {
    final corTitulo = cor ?? theme.primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: corTitulo,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: corTitulo.withValues(alpha: 0.15), thickness: 1),
      ],
    );
  }

  // Campo de entrada estilizado
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