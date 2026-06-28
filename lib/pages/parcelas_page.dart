import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    ParcelasService.limparCache();
    final dados = await ParcelasService.carregarParcelas();
    
    if (!mounted) return;
    
    setState(() {
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
    await carregar();
  }

  Future<void> excluir(String id) async {
    await ParcelasService.deletarParcelas(id);
    await carregar();
  }

  void abrirFormularioCriacao() {
    final descCtrl = TextEditingController();
    final valorTotalCtrl = TextEditingController();
    final qtdCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A1128),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 24, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("NOVO CONTRATO PARCELADO", style: TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Descrição / Estabelecimento")),
            TextField(controller: valorTotalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor Total da Compra (R\$)")),
            TextField(controller: qtdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantidade de Parcelas")),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final total = double.tryParse(valorTotalCtrl.text) ?? 0;
                final parcelasQtd = int.tryParse(qtdCtrl.text) ?? 1;
                if (descCtrl.text.isNotEmpty && total > 0) {
                  await ParcelasService.cadastrarCompraParcelada(
                    descricao: descCtrl.text,
                    valorTotal: total,
                    totalParcelas: parcelasQtd,
                  );
                  Navigator.pop(ctx);
                  carregar();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8), foregroundColor: const Color(0xFF060B16)),
              child: const Text("LANÇAR NO SISTEMA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormularioCriacao,
        backgroundColor: const Color(0xFF00B4D8),
        foregroundColor: const Color(0xFF060B16),
        child: const Icon(Icons.add_card_rounded),
      ),
      body: FundoCosmico(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: carregando
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
                    : parcelas.isEmpty
                        ? const Center(child: Text("Nenhum contrato ativo em órbita.", style: TextStyle(color: Colors.white38)))
                        : ListView.builder(
                            itemCount: parcelas.length,
                            itemBuilder: (context, index) {
                              final p = parcelas[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A1128),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(p.descricao.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                        ),
                                        Text("Fat. ${p.parcelaAtual}/${p.totalParcelas}", style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                                      ],
                                    ),
                                    const Divider(height: 20, color: Colors.white10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("VALOR DA PARCELA", style: TextStyle(color: Colors.white38, fontSize: 10)),
                                            Text("R\$ ${p.valorParcela.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.white38, size: 20),
                                              onPressed: () => ajustarTempo(p.id, false),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4D8), size: 20),
                                              onPressed: () => ajustarTempo(p.id, true),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                              onPressed: () => excluir(p.id),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
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
    );
  }
}