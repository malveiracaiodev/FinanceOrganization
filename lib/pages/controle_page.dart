import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../services/parcelas_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class ControlePage extends StatefulWidget {
  final Function(int)? onSelectTab; // 🔥 Adicionado callback para sincronia perfeita com as abas

  const ControlePage({super.key, this.onSelectTab});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final receitaController = TextEditingController();
  final despesaController = TextEditingController();
  final previstoController = TextEditingController();

  Usuario? usuario;
  ControleFinanceiro? controle;
  double totalParcelasMes = 0;

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final usuarioCarregado = await PreferencesService.carregarUsuario();
    final controleCarregado = await ControleService.carregarControle();
    final parcelas = await ParcelasService.calcularTotalMes();

    if (!mounted) return;

    setState(() {
      usuario = usuarioCarregado;
      controle = controleCarregado;
      totalParcelasMes = parcelas;
      carregando = false;
    });
  }

  bool _valorValido(String text) {
    final valor = double.tryParse(text.replaceAll(',', '.'));
    return valor != null && valor > 0;
  }

  Future<void> adicionarReceita() async {
    if (!_valorValido(receitaController.text)) return;
    final valor = double.parse(receitaController.text.replaceAll(',', '.'));
    await ControleService.adicionarReceita(valor);
    receitaController.clear();
    await carregarDados();
  }

  Future<void> adicionarDespesa() async {
    if (!_valorValido(despesaController.text)) return;
    final valor = double.parse(despesaController.text.replaceAll(',', '.'));
    await ControleService.adicionarDespesa(valor);
    despesaController.clear();
    await carregarDados();
  }

  Future<void> adicionarPrevisto() async {
    if (!_valorValido(previstoController.text)) return;
    final valor = double.parse(previstoController.text.replaceAll(',', '.'));
    await ControleService.adicionarPrevisto(valor);
    previstoController.clear();
    await carregarDados();
  }

  Future<void> encerrarMes() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1E),
        title: const Text(
          'ENCERRAR CICLO MENSAL',
          style: TextStyle(color: AstraTheme.secondary, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Confirmar o encerramento do ciclo atual? Os dados correntes serão compilados no histórico gerencial e o painel redefinido para o próximo mês.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('CONFIRMAR FECHAMENTO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ControleService.encerrarMes();
    await carregarDados();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ciclo mensal encerrado e arquivado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final saldo = controle != null && usuario != null
        ? controle!.saldoFinal(usuario!.ganhoFixo, totalParcelasDoMes: totalParcelasMes)
        : 0.0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab), // 🔥 Injetado controle síncrono no Drawer
      body: FundoCosmico(
        child: SafeArea(
          child: carregando
              ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 🌌 Barra de Navegação Superior
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Text(
                          "LANÇAMENTOS DE FLUXO",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 💎 Mostrador de Saldo Real Dinâmico
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'SALDO ATUAL REAL',
                            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'R\$ ${saldo.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 34,
                              color: AstraTheme.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📊 Painel de Resumos
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _linhaResumo('Renda Base (Salário)', usuario!.ganhoFixo, Colors.cyanAccent),
                          _linhaResumo('Receitas Extras', controle!.receitasExtras, Colors.greenAccent),
                          _linhaResumo('Despesas Diárias', controle!.despesas, Colors.redAccent),
                          _linhaResumo('Despesas Previstas', controle!.despesasPrevistas, Colors.orangeAccent),
                          _linhaResumo('Fatura de Parcelas', totalParcelasMes, const Color(0xFFE040FB)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 🛠️ Módulos de Entrada de Dados Profissionalizados
                    _campoFinanceiro(
                      controller: receitaController,
                      titulo: 'RECEITA EXTRA',
                      botao: 'INJETAR',
                      onPressed: adicionarReceita,
                      corIcone: Colors.greenAccent,
                      icone: Icons.add_chart,
                    ),

                    const SizedBox(height: 16),

                    _campoFinanceiro(
                      controller: despesaController,
                      titulo: 'REGISTRAR DESPESA',
                      botao: 'DEBITAR',
                      onPressed: adicionarDespesa,
                      corIcone: Colors.redAccent,
                      icone: Icons.money_off,
                    ),

                    const SizedBox(height: 16),

                    _campoFinanceiro(
                      controller: previstoController,
                      titulo: 'PROJETAR DESPESA PREVISTA',
                      botao: 'PROJETAR',
                      onPressed: adicionarPrevisto,
                      corIcone: Colors.orangeAccent,
                      icone: Icons.analytics,
                    ),

                    const SizedBox(height: 32),

                    // 🚨 Botão de Fechamento de Mês Corporativo
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: encerrarMes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.archive, color: Colors.redAccent, size: 20),
                        label: const Text(
                          'CONCLUIR E FECHAR MÊS CORRENTE',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _linhaResumo(String titulo, double valor, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _campoFinanceiro({
    required TextEditingController controller,
    required String titulo,
    required String botao,
    required VoidCallback onPressed,
    required Color corIcone,
    required IconData icone,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: corIcone, size: 18),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      prefixStyle: TextStyle(color: corIcone, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      // Removemos as bordas inline e deixamos herdar do inputDecorationTheme do AstraTheme!
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(botao, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}