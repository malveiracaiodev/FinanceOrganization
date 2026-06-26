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
  final Function(int)? onSelectTab; // Callback para sincronia perfeita com as abas

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

  @override
  void dispose() {
    receitaController.dispose();
    despesaController.dispose();
    previstoController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    try {
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
    } catch (e) {
      debugPrint("Erro ao auditar dados de fluxo: $e");
      if (mounted) setState(() => carregando = false);
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ENCERRAR CICLO MENSAL',
          style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.bold),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CONFIRMAR FECHAMENTO', style: TextStyle(fontWeight: FontWeight.bold)),
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
        content: Text('Ciclo mensal encerrado e arquivado com sucesso!'),
        backgroundColor: Color(0xFF0B1424),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = controle != null && usuario != null
        ? controle!.saldoFinal(usuario!.ganhoFixo, totalParcelasDoMes: totalParcelasMes)
        : 0.0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab),
      body: FundoCosmico(
        child: SafeArea(
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 🌌 Barra de Navegação Superior
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Text(
                          "LANÇAMENTOS DE FLUXO",
                          style: TextStyle(
                            color: Color(0xFF00B4D8),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 💎 Mostrador de Saldo Real Dinâmico
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1424).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.15)),
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
                              fontSize: 36,
                              color: Color(0xFF8CE8FF),
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📊 Painel de Resumos Protegido contra Nulos (Null-Safe)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1424).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _linhaResumo('Renda Base (Salário)', usuario?.ganhoFixo ?? 0.0, const Color(0xFF00B4D8)),
                          _linhaResumo('Receitas Extras', controle?.receitasExtras ?? 0.0, const Color(0xFF8CE8FF)),
                          _linhaResumo('Despesas Diárias', controle?.despesas ?? 0.0, const Color(0xFFFF6B6B)),
                          _linhaResumo('Despesas Previstas', controle?.despesasPrevistas ?? 0.0, Colors.orangeAccent),
                          _linhaResumo('Fatura de Parcelas', totalParcelasMes, const Color(0xFFE040FB)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🛠️ Módulos de Entrada de Dados
                    _campoFinanceiro(
                      controller: receitaController,
                      titulo: 'RECEITA EXTRA',
                      botao: 'INJETAR',
                      onPressed: adicionarReceita,
                      corIcone: const Color(0xFF8CE8FF),
                      icone: Icons.add_chart_rounded,
                    ),

                    const SizedBox(height: 16),

                    _campoFinanceiro(
                      controller: despesaController,
                      titulo: 'REGISTRAR DESPESA',
                      botao: 'DEBITAR',
                      onPressed: adicionarDespesa,
                      corIcone: const Color(0xFFFF6B6B),
                      icone: Icons.money_off_rounded,
                    ),

                    const SizedBox(height: 16),

                    _campoFinanceiro(
                      controller: previstoController,
                      titulo: 'PROJETAR DESPESA PREVISTA',
                      botao: 'PROJETAR',
                      onPressed: adicionarPrevisto,
                      corIcone: Colors.orangeAccent,
                      icone: Icons.analytics_rounded,
                    ),

                    const SizedBox(height: 32),

                    // 🚨 Botão de Fechamento de Mês Corporativo
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: encerrarMes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.05),
                          side: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.archive_rounded, color: Color(0xFFFF6B6B), size: 20),
                        label: const Text(
                          'CONCLUIR E FECHAR MÊS CORRENTE',
                          style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
            style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
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
        color: const Color(0xFF0B1424).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      prefixStyle: TextStyle(color: corIcone, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    backgroundColor: corIcone.withValues(alpha: 0.8),
                    foregroundColor: const Color(0xFF060B16),
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