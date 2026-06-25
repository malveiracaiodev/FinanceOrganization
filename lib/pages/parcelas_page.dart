import 'package:flutter/material.dart';
import '../models/parcela.dart';
import '../services/parcelas_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class ParcelasPage extends StatefulWidget {
  final Function(int)? onSelectTab; // 🔥 Callback para sincronizar abas do painel principal

  const ParcelasPage({super.key, this.onSelectTab});

  @override
  State<ParcelasPage> createState() => _ParcelasPageState();
}

class _ParcelasPageState extends State<ParcelasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Parcela> parcelas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final dados = await ParcelasService.carregarParcelas();
    if (!mounted) return;
    setState(() {
      parcelas = dados.where((p) => !p.finalizada).toList();
      carregando = false;
    });
  }

  Future<void> ajustarTempo(String id, bool adiantar) async {
    if (adiantar) {
      await ParcelasService.adiantarContrato(id);
    } else {
      await ParcelasService.atrasarContrato(id);
    }
    await carregar();
  }

  Future<void> excluir(String id) async {
    await ParcelasService.deletarParcelas(id);
    await carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab), // 🔥 Menu integrado
      backgroundColor: const Color(0xFF060B16),
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra Superior Corporativa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      "GERENCIAMENTO DE CONTRATOS",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Parcelamentos",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Compromissos de longo prazo sob auditoria.",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                      : parcelas.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhum parcelamento ativo em aberto.",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.builder(
                              itemCount: parcelas.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final p = parcelas[index];
                                final double progresso = p.totalParcelas > 0 
                                    ? p.parcelaAtual / p.totalParcelas 
                                    : 0.0;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1424).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.descricao,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          Text(
                                            "${p.parcelaAtual.toString().padLeft(2, '0')}/${p.totalParcelas.toString().padLeft(2, '0')}",
                                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Impacto mensal: R\$ ${p.valorParcela.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Barra Neon de Progresso
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progresso.clamp(0.0, 1.0),
                                          backgroundColor: Colors.white.withOpacity(0.05),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Painel de Operações da Parcela
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: "Retroceder Parcela",
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent, size: 20),
                                                onPressed: () => ajustarTempo(p.id, false),
                                              ),
                                              IconButton(
                                                tooltip: "Avançar/Quitar Parcela",
                                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E5FF), size: 20),
                                                onPressed: () => ajustarTempo(p.id, true),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            tooltip: "Remover Parcelamento",
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () => excluir(p.id),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}