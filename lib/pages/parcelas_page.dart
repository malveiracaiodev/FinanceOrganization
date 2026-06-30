import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/parcela.dart';
import '../services/parcelas_service.dart';
import '../widgets/fundo_cosmico.dart';

class ParcelasPage extends StatefulWidget {
  final Function(int)? onSelectTab;
  const ParcelasPage({super.key, this.onSelectTab});

  @override
  State<ParcelasPage> createState() => ParcelasPageState();
}

class ParcelasPageState extends State<ParcelasPage> {
  List<Parcela> parcelas = [];
  bool carregando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carregar();
  }

Future<void> carregar() async {
    setState(() => carregando = true);
    try {
      // CORREÇÃO: Alterado de 'carregarParcelas()' para 'carregar()'
      final dados = await ParcelasService.carregar();
      if (!mounted) return;
      
      setState(() => parcelas = dados.where((p) => p.ativa).toList());
    } catch (e) {
      debugPrint("Erro ao carregar parcelas: $e");
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  // Função para excluir ou quitar parcelamento com diálogo de confirmação
  Future<void> _excluirParcela(Parcela parcela) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Parcelamento?"),
        content: Text("Deseja interromper ou remover o parcelamento '${parcela.descricao}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AstraTheme.dangerColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        // ✅ CORREÇÃO: Utilizando a assinatura correta do seu ParcelasService
        await ParcelasService.deletarParcelas(parcela.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AstraTheme.dangerColor,
            content: Text("Parcelamento removido do sistema!"),
          ),
        );

        carregar(); // Força a atualização da lista após deletar
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao remover o parcelamento.")),
        );
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

  // --- COMPONENTES AUXILIARES ---

  // Cabeçalho da página com botão de atualizar
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
                "SISTEMA DE COMPRAS",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Contratos e Parcelas",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
            onPressed: carregar,
            tooltip: "Atualizar Parcelas",
          )
        ],
      ),
    );
  }

  // Gerenciador do corpo da página (Loading, Vazio ou Lista de Itens)
  Widget _buildConteudo(ThemeData theme) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AstraTheme.primary),
      );
    }

    if (parcelas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card_off_rounded,
                size: 64,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Text(
                "Nenhum parcelamento ativo",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Cadastre novas compras parceladas usando o botão (+) na Dashboard.",
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: parcelas.length,
      itemBuilder: (ctx, i) {
        final item = parcelas[i];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Ícone cósmico em destaque
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Detalhes centrais da compra parcelada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.descricao,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ✅ CORREÇÃO: Utilizando o 'valorParcela' dinâmico direto do serviço
                      Text(
                        "R\$ ${item.valorParcela.toStringAsFixed(2)} / mês",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total de R\$ ${item.valorTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // Chip indicador do progresso e Botão de Remover
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // ✅ CORREÇÃO: Exibe o andamento real do contrato (Ex: 1 de 12)
                      child: Text(
                        "${item.parcelaAtual} de ${item.totalParcelas}",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: AstraTheme.dangerColor),
                      onPressed: () => _excluirParcela(item),
                      tooltip: "Excluir Parcelamento",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}