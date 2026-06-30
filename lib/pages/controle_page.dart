import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importação essencial para formatadores de entrada

import '../core/theme/app_theme.dart'; // Import do seu tema para acessar as cores de estado
import '../services/controle_service.dart';
import '../widgets/fundo_cosmico.dart';

class ControlePage extends StatefulWidget {
  final Function(int)? onSelectTab;
  const ControlePage({super.key, this.onSelectTab});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  
  bool processando = false;

  @override
  void dispose() {
    controller.dispose(); // CORREÇÃO: Previne Memory Leaks ao sair da tela
    super.dispose();
  }

  Future<void> _processar(bool ehReceita) async {
    // Valida se o formulário foi preenchido de forma correta
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // CORREÇÃO: Suporte nacional para separador decimal de vírgula
    final valor = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O valor do lançamento deve ser maior que zero.")),
      );
      return;
    }

    setState(() => processando = true);

    try {
      if (ehReceita) {
        await ControleService.adicionarReceita(valor);
      } else {
        await ControleService.adicionarDespesa(valor);
      }

      if (!mounted) return;

      // Feedback visual personalizado de acordo com o tipo de movimentação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ehReceita ? AstraTheme.successColor : AstraTheme.dangerColor,
          duration: const Duration(seconds: 2),
          content: Text(
            ehReceita 
                ? "Receita de R\$ ${valor.toStringAsFixed(2)} adicionada com sucesso!" 
                : "Despesa de R\$ ${valor.toStringAsFixed(2)} registrada!",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );

      // Limpa o campo numérico após o sucesso
      controller.clear();

      // Redireciona de volta para a tela inicial (Dashboard / Index 0) usando o seu callback
      if (widget.onSelectTab != null) {
        widget.onSelectTab!(0);
      }
    } catch (e) {
      debugPrint("Erro ao registrar lançamento: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro crítico ao salvar o lançamento. Tente novamente.")),
      );
    } finally {
      if (mounted) {
        setState(() => processando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  
                  // Ícone superior imersivo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_horizontal_circle_outlined,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "LANÇAMENTO RÁPIDO",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Registrar Movimentação",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Card centralizado para digitação do valor monetário
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DIGITE O VALOR",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Por favor, informe o valor";
                              }
                              final numVal = double.tryParse(val.replaceAll(',', '.'));
                              if (numVal == null || numVal <= 0) {
                                return "Informe uma quantia maior que zero";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixText: "R\$ ",
                              prefixStyle: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botões de Ação de Lado a Lado ou Indicador de Carregamento
                  if (processando)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    Row(
                      children: [
                        // Botão Despesa (Saída de Dinheiro)
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => _processar(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AstraTheme.dangerColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    "DESPESA",
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Botão Receita (Entrada de Dinheiro)
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => _processar(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AstraTheme.successColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward_rounded, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    "RECEITA",
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}