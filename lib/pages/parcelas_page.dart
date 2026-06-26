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
    // 🔥 Sincroniza limpando o cache estático para garantir dados frescos do SharedPreferences
    ParcelasService.limparCache();
    final dados = await ParcelasService.carregarParcelas();
    
    if (!mounted) return;
    
    setState(() {
      // 🔥 CORRIGIDO: Vinculado à propriedade real 'ativa' do seu modelo de dados
      parcelas = dados.where((p) => p.ativa).toList();
      carregando = false;
    });
  }

  Future<void> ajustarTempo(String id, bool adiantar) async {
    if (adiantar) {
      await ParcelasService.adiantarContrato(id);
    } else {
      await ParcelasService.atrasarContrato(id);
    }
    // Recarrega a tela imediatamente após alterar o estado no banco
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
      drawer: AppDrawer(onSelectTab: widget.onSelectTab), // Menu integrado
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra Superior Estilo Cabine Intergaláctica
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      "SISTEMA DE CONTRATOS",
                      style: TextStyle(
                        color: Color(0xFF00B4D8), // Azul Neon Stitch
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Compras Parceladas",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Compromissos de longo prazo sob auditoria orbital.",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
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
                                    color: const Color(0xFF0B1424).withValues(alpha: 0.6), // Sintaxe moderna
                                    borderRadius: BorderRadius.circular(20), // Bordas mais arredondadas Stitch UI
                                    border: Border.all(color: const Color(0xFF1A2740), width: 1.5),
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
                                            style: const TextStyle(color: Color(0xFF8CE8FF), fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Impacto mensal: R\$ ${p.valorParcela.toStringAsFixed(2)}",
                                        style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Barra Neon de Progresso Otimizada
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progresso.clamp(0.0, 1.0),
                                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Painel de Operações da Parcela Estilizado
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: "Retroceder Parcela",
                                                icon: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent, size: 22),
                                                onPressed: () => ajustarTempo(p.id, false),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                tooltip: "Avançar/Quitar Parcela",
                                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4D8), size: 22),
                                                onPressed: () => ajustarTempo(p.id, true),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            tooltip: "Remover Parcelamento",
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
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