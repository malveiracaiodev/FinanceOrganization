import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/historico_mensal.dart';
import '../services/historico_service.dart';
import '../widgets/fundo_cosmico.dart';

class HistoricoPage extends StatefulWidget {
  final Function(int)? onSelectTab;
  const HistoricoPage({super.key, this.onSelectTab});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<HistoricoMensal> historico = [];
  bool carregando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);
    try {
      final data = await HistoricoService.carregar();
      if (!mounted) return;
      setState(() => historico = data);
    } catch (e) {
      debugPrint("Erro ao carregar histórico: $e");
    } finally {
      if (mounted) {
        setState(() => carregando = false);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              Expanded(
                child: _buildConteudo(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES DA TELA ---

  // Cabeçalho unificado com botão de atualização manual
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "HISTÓRICO FINANCEIRO",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Fechamentos Mensais",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
            onPressed: _carregar,
            tooltip: "Atualizar Histórico",
          )
        ],
      ),
    );
  }

  // Gerencia qual estado visual exibir de acordo com o carregamento e dados
  Widget _buildConteudo(ThemeData theme) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AstraTheme.primary),
      );
    }

    if (historico.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              "Histórico Vazio",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Seus fechamentos mensais aparecerão aqui.",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Lista de fechamentos mensais
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: historico.length,
      itemBuilder: (ctx, i) {
        final item = historico[i];
        final saldoPositivo = item.saldo >= 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo do card: Nome do Mês e Badge de Status Financeiro
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.mesAno.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    _buildStatusBadge(saldoPositivo),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(height: 16),

                // Base do card: Demonstrativo simplificado de Receitas, Despesas e Saldo Final
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ⚠️ ATENÇÃO: Se as propriedades do seu modelo 'HistoricoMensal' forem nomeadas de forma diferente, 
                    // ajuste os nomes abaixo (ex: se for 'item.totalRecebido' em vez de 'item.receitas')
                    _buildMetricaColuna(
                      label: "RECEITAS",
                      valor: item.receitas,
                      color: AstraTheme.successColor,
                    ),
                    _buildMetricaColuna(
                      label: "DESPESAS",
                      valor: item.despesas,
                      color: AstraTheme.dangerColor,
                    ),
                    _buildMetricaColuna(
                      label: "SALDO FINAL",
                      valor: item.saldo,
                      color: saldoPositivo ? AstraTheme.primary : AstraTheme.dangerColor,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Emblema visual de Superávit / Déficit do mês
  Widget _buildStatusBadge(bool saldoPositivo) {
    final cor = saldoPositivo ? AstraTheme.successColor : AstraTheme.dangerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        saldoPositivo ? "SUPERÁVIT" : "DÉFICIT",
        style: TextStyle(
          color: cor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Coluna individual para demonstrar os valores (Receita, Despesa e Saldo)
  Widget _buildMetricaColuna({
    required String label,
    required double valor,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "R\$ ${valor.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}