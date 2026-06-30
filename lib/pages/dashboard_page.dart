import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../models/usuario.dart';
import '../services/preferences_service.dart';
import '../services/controle_service.dart';
import '../services/parcelas_service.dart'; 
import '../widgets/fundo_cosmico.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onSelectTab;
  const DashboardPage({super.key, this.onSelectTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Usuario? usuario;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carregarDados(); 
  }

  Future<void> carregarDados() async {
    final res = await PreferencesService.carregarUsuario();
    if (!mounted) return;
    setState(() {
      usuario = res;
      carregando = false;
    });
  }

  void _abrirModalLancamento(bool ehReceita) {
    final formKey = GlobalKey<FormState>();
    final valorController = TextEditingController();
    bool salvandoInterno = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          ehReceita ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: ehReceita ? AstraTheme.successColor : AstraTheme.dangerColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ehReceita ? "Adicionar Receita" : "Registrar Despesa",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Informe o valor";
                        final v = double.tryParse(val.replaceAll(',', '.'));
                        if (v == null || v <= 0) return "Valor deve ser maior que zero";
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Valor do Lançamento",
                        prefixText: "R\$ ",
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ehReceita ? AstraTheme.successColor : AstraTheme.dangerColor,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: salvandoInterno
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => salvandoInterno = true);

                                final valor = double.parse(valorController.text.replaceAll(',', '.'));

                                // CORREÇÃO: Guarda instâncias antes da brecha assíncrona (Previne use_build_context_synchronously)
                                final navigator = Navigator.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);

                                try {
                                  if (ehReceita) {
                                    await ControleService.adicionarReceita(valor);
                                  } else {
                                    await ControleService.adicionarDespesa(valor);
                                  }

                                  navigator.pop(); 
                                  
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: ehReceita ? AstraTheme.successColor : AstraTheme.dangerColor,
                                      content: Text(ehReceita ? "Receita registrada!" : "Despesa registrada!"),
                                    ),
                                  );
                                  carregarDados(); 
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(content: Text("Falha ao salvar lançamento.")),
                                  );
                                } finally {
                                  setModalState(() => salvandoInterno = false);
                                }
                              },
                        child: salvandoInterno
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : Text(ehReceita ? "SALVAR RECEITA" : "REGISTRAR DESPESA"),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _abrirModalParcela() {
    final formKey = GlobalKey<FormState>();
    final descricaoController = TextEditingController();
    final valorTotalController = TextEditingController();
    final parcelasController = TextEditingController();
    bool salvandoInterno = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: AstraTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Nova Compra Parcelada",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descricaoController,
                      validator: (val) => val == null || val.trim().isEmpty ? "Informe a descrição" : null,
                      decoration: const InputDecoration(
                        labelText: "Descrição (ex: Notebook, Celular)",
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: valorTotalController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontFamily: 'monospace'),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Insira o valor";
                              final v = double.tryParse(val.replaceAll(',', '.'));
                              if (v == null || v <= 0) return "Incorreto";
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Valor Total",
                              prefixText: "R\$ ",
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: parcelasController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontFamily: 'monospace'),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Qtd.";
                              final p = int.tryParse(val);
                              if (p == null || p <= 1) return "Min. 2";
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Nº Vezes",
                              suffixText: "x",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AstraTheme.primary,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: salvandoInterno
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => salvandoInterno = true);

                                final descricao = descricaoController.text.trim();
                                final valorTotal = double.parse(valorTotalController.text.replaceAll(',', '.'));
                                final qtdParcelas = int.parse(parcelasController.text);

                                // CORREÇÃO: Guarda referências de navegação antes de await (use_build_context_synchronously)
                                final navigator = Navigator.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);

                                try {
                                  await ParcelasService.cadastrarCompraParcelada(
                                    descricao: descricao,
                                    valorTotal: valorTotal,
                                    totalParcelas: qtdParcelas,
                                  );

                                  navigator.pop(); 
                                  
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AstraTheme.primary,
                                      content: Text("Compra parcelada cadastrada e agendada!"),
                                    ),
                                  );
                                  carregarDados(); 
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(content: Text("Falha ao salvar parcelamento.")),
                                  );
                                } finally {
                                  setModalState(() => salvandoInterno = false);
                                }
                              },
                        child: salvandoInterno
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text("GERAR PARCELAMENTO"),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FundoCosmico(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: AstraTheme.primary))
            : SafeArea(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Olá, ${usuario?.nome ?? 'Piloto'}!",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario?.cargo != null && usuario!.cargo.isNotEmpty
                                  ? "${usuario?.cargo} na ${usuario?.empresa}"
                                  : "Tripulação do Finanças Mark I",
                              // CORREÇÃO: Alterado de 'white50' para 'white54'
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white54, 
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person_rounded, color: theme.primaryColor),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),

                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "SALDO ATUAL",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Icon(Icons.satellite_alt_rounded, color: theme.primaryColor, size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "R\$ ${usuario?.saldoAtual.toStringAsFixed(2) ?? '0,00'}",
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 36,
                                color: theme.primaryColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withValues(alpha: 0.05)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Renda Base Cadastrada",
                                  // CORREÇÃO: Alterado de 'white50' para 'white54'
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                                ),
                                Text(
                                  "R\$ ${usuario?.ganhoFixo.toStringAsFixed(2) ?? '0,00'}",
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "SISTEMAS DE CONTROLE",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _botaoAcaoRapida(
                          icon: Icons.add_chart_rounded,
                          label: "Receita",
                          color: AstraTheme.successColor,
                          onTap: () => _abrirModalLancamento(true),
                        ),
                        _botaoAcaoRapida(
                          icon: Icons.analytics_outlined,
                          label: "Despesa",
                          color: AstraTheme.dangerColor,
                          onTap: () => _abrirModalLancamento(false),
                        ),
                        _botaoAcaoRapida(
                          icon: Icons.credit_card_rounded,
                          label: "Parcela",
                          color: AstraTheme.primary,
                          onTap: _abrirModalParcela,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AstraTheme.secondary, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Todas as transações e parcelamentos gravados são sincronizados automaticamente com o seu Histórico Mensal.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  height: 1.3,
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
    );
  }

  Widget _botaoAcaoRapida({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}