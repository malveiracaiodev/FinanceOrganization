import 'package:flutter/material.dart';
import '../models/controle_financeiro.dart';
import '../models/usuario.dart';
import '../services/controle_service.dart';
import '../services/preferences_service.dart';
import '../services/parcelas_service.dart';
import '../widgets/fundo_cosmico.dart';

class ControlePage extends StatefulWidget {
  final Function(int)? onSelectTab;

  const ControlePage({super.key, this.onSelectTab});

  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> {
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
    final resUsuario = await PreferencesService.carregarUsuario();
    final resControle = await ControleService.carregarControle();
    final resParcelas = await ParcelasService.calcularTotalMes();

    if (!mounted) return;

    setState(() {
      usuario = resUsuario;
      controle = resControle;
      totalParcelasMes = resParcelas;
      carregando = false;
    });
  }

  Future<void> lancarReceita() async {
    final valor = double.tryParse(receitaController.text.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) return;
    setState(() => carregando = true);
    await ControleService.adicionarReceita(valor);
    receitaController.clear();
    await carregarDados();
  }

  Future<void> lancarDespesa() async {
    final valor = double.tryParse(despesaController.text.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) return;
    setState(() => carregando = true);
    await ControleService.adicionarDespesa(valor);
    despesaController.clear();
    await carregarDados();
  }

  Future<void> lancarPrevisto() async {
    final valor = double.tryParse(previstoController.text.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) return;
    setState(() => carregando = true);
    await ControleService.adicionarPrevisto(valor);
    previstoController.clear();
    await carregarDados();
  }

  Future<void> executarVirada() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1128),
        title: const Text("FECHAR CICLO MENSAL?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Isto irá snapshotar os teus dados atuais no histórico, rodar faturas de parcelas e limpar a folha do mês atual. Continuar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ABORTAR")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("CONFIRMAR")),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => carregando = true);
      await ControleService.encerrarMes();
      await carregarDados();
      widget.onSelectTab?.call(0); // Volta para a Dashboard automaticamente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSecaoLancamento("INJETAR RECEITA EXTRA", "Lançar Ganho", receitaController, Colors.greenAccent, lancarReceita),
                    const SizedBox(height: 20),
                    _buildSecaoLancamento("REGISTAR DESPESA À VISTA", "Lançar Débito", despesaController, Colors.redAccent, lancarDespesa),
                    const SizedBox(height: 20),
                    _buildSecaoLancamento("RESERVAR GASTO PREVISTO", "Salvar Alocação", previstoController, Colors.orangeAccent, lancarPrevisto),
                    const SizedBox(height: 32),

                    // Card Virada de Mês
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140B1B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.autorenew_rounded, color: Colors.purpleAccent),
                              SizedBox(width: 8),
                              Text("VIRADA DE MÊS CRONOLÓGICA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Caso queiras forçar a transição de ciclo financeiro para o próximo mês agora mesmo, aciona o propulsor abaixo.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: executarVirada,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("PROMOVER VIRADA DE CICLO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSecaoLancamento(String titulo, String botao, TextEditingController controller, Color corIcone, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corIcone.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: corIcone, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
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