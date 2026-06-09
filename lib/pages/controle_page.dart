import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class ControlePage extends StatefulWidget {
  const ControlePage({super.key});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  final receitaController = TextEditingController();
  final despesaController = TextEditingController();
  final previstoController = TextEditingController();

  Usuario? usuario;
  ControleFinanceiro? controle;

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final usuarioCarregado =
        await PreferencesService.carregarUsuario();

    final controleCarregado =
        await ControleService.carregarControle();

    if (!mounted) return;

    setState(() {
      usuario = usuarioCarregado;
      controle = controleCarregado;
      carregando = false;
    });
  }

  bool _valorValido(String text) {
    final valor =
        double.tryParse(text.replaceAll(',', '.'));
    return valor != null && valor > 0;
  }

  Future<void> adicionarReceita() async {
    if (!_valorValido(receitaController.text)) return;

    final valor =
        double.parse(receitaController.text.replaceAll(',', '.'));

    await ControleService.adicionarReceita(valor);

    receitaController.clear();
    await carregarDados();
  }

  Future<void> adicionarDespesa() async {
    if (!_valorValido(despesaController.text)) return;

    final valor =
        double.parse(despesaController.text.replaceAll(',', '.'));

    await ControleService.adicionarDespesa(valor);

    despesaController.clear();
    await carregarDados();
  }

  Future<void> adicionarPrevisto() async {
    if (!_valorValido(previstoController.text)) return;

    final valor =
        double.parse(previstoController.text.replaceAll(',', '.'));

    await ControleService.adicionarPrevisto(valor);

    previstoController.clear();
    await carregarDados();
  }

  Future<void> encerrarMes() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Mês'),
        content: const Text(
          'Deseja realmente encerrar o mês atual? Isso irá zerar os dados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ControleService.encerrarMes();

    await carregarDados();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mês encerrado com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = controle != null && usuario != null
        ? controle!.saldoFinal(usuario!.ganhoFixo)
        : 0.0;

    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: SafeArea(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Olá, ${usuario!.nome}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('Saldo Atual'),
                            const SizedBox(height: 10),
                            Text(
                              'R\$ ${saldo.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 30,
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _linhaResumo(
                              'Salário Base',
                              usuario!.ganhoFixo,
                            ),
                            _linhaResumo(
                              'Receitas Extras',
                              controle!.receitasExtras,
                            ),
                            _linhaResumo(
                              'Despesas',
                              controle!.despesas,
                            ),
                            _linhaResumo(
                              'Previstos',
                              controle!.despesasPrevistas,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _campoFinanceiro(
                      controller: receitaController,
                      titulo: 'Receita Extra',
                      botao: 'Adicionar Receita',
                      onPressed: adicionarReceita,
                    ),

                    const SizedBox(height: 20),

                    _campoFinanceiro(
                      controller: despesaController,
                      titulo: 'Despesa',
                      botao: 'Adicionar Despesa',
                      onPressed: adicionarDespesa,
                    ),

                    const SizedBox(height: 20),

                    _campoFinanceiro(
                      controller: previstoController,
                      titulo: 'Despesa Prevista',
                      botao: 'Adicionar Previsto',
                      onPressed: adicionarPrevisto,
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: encerrarMes,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Encerrar Mês'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _linhaResumo(String titulo, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Text('R\$ ${valor.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _campoFinanceiro({
    required TextEditingController controller,
    required String titulo,
    required String botao,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(botao),
            ),
          ],
        ),
      ),
    );
  }
}