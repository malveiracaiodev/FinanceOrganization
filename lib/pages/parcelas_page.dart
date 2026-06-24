import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/parcela.dart';
import '../services/parcelas_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class ParcelasPage extends StatefulWidget {
  const ParcelasPage({super.key});

  @override
  State<ParcelasPage> createState() => _ParcelasPageState();
}

class _ParcelasPageState extends State<ParcelasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Parcela> _parcelas = [];
  bool _carregando = true;

  // Controllers para o formulário de nova parcela
  final _tituloController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _qtdParcelasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  Future<void> _atualizarLista() async {
    setState(() => _carregando = true);
    final lista = await ParcelasService.carregar();
    setState(() {
      _parcelas = lista;
      _carregando = false;
    });
  }

  Future<void> _removerParcela(String id) async {
    await ParcelasService.remover(id);
    _atualizarLista();
  }

  void _abrirModalCadastro() {
    _tituloController.clear();
    _valorTotalController.clear();
    _qtdParcelasController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NOVO PARCELAMENTO",
              style: TextStyle(
                color: AstraTheme.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _tituloController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Título da Compra (Ex: Notebook)",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valorTotalController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Valor Total (R\$)",
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _qtdParcelasController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nº de Parcelas",
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final titulo = _tituloController.text.trim();
                  final valorTotal = double.tryParse(_valorTotalController.text.replaceAll(',', '.'));
                  final parcelas = int.tryParse(_qtdParcelasController.text);

                  if (titulo.isEmpty || valorTotal == null || parcelas == null || parcelas <= 0) {
                    return;
                  }

                  final nova = Parcela(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titulo: titulo,
                    valorTotal: valorTotal,
                    quantidadeParcelas: parcelas,
                    mesInicio: DateTime.now().month,
                    anoInicio: DateTime.now().year,
                  );

                  await ParcelasService.adicionar(nova);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _atualizarLista();
                },
                child: const Text("LANÇAR NA FATURA"),
              ),
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
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AstraTheme.primary,
        onPressed: _abrirModalCadastro,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: FundoCosmico(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra Superior
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      "COMPRAS PARCELADAS",
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

                // Listagem Dinâmica
                Expanded(
                  child: _carregando
                      ? const Center(child: CircularProgressIndicator(color: AstraTheme.primary))
                      : _parcelas.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhum parcelamento ativo na órbita.",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _parcelas.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final p = _parcelas[index];
                                final valorParcela = p.valorTotal / p.quantidadeParcelas;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      p.titulo,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "Total: R\$ ${p.valorTotal.toStringAsFixed(2)} | Mês: ${p.quantidadeParcelas}x",
                                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "R\$ ${valorParcela.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Color(0xFFE040FB),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () => _removerParcela(p.id),
                                        ),
                                      ],
                                    ),
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