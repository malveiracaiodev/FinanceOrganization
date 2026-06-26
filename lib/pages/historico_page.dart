import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/historico_mensal.dart';
import '../services/historico_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';

class HistoricoPage extends StatefulWidget {
  final Function(int)? onSelectTab; // Callback para controle integrado da navegação

  const HistoricoPage({super.key, this.onSelectTab});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<HistoricoMensal> historico = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await HistoricoService.carregar();

    if (!mounted) return;

    setState(() {
      historico = data;
      carregando = false;
    });
  }

  Future<void> editarMes(int index) async {
    final item = historico[index];

    final ganhoController = TextEditingController(text: item.ganhoFixo.toString());
    final adicionaisController = TextEditingController(text: item.ganhosAdicionais.toString());
    final gastosController = TextEditingController(text: item.gastosTotais.toString());

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "AJUSTAR FECHAMENTO: ${item.mesAno}",
          style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField("Ganho Fixo (R\$)", ganhoController),
            _buildDialogField("Ganhos Adicionais (R\$)", adicionaisController),
            _buildDialogField("Gastos Totais (R\$)", gastosController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              foregroundColor: const Color(0xFF060B16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("SALVAR ALTERAÇÕES", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final novoFixo = double.tryParse(ganhoController.text.replaceAll(',', '.')) ?? item.ganhoFixo;
    final novoAdicional = double.tryParse(adicionaisController.text.replaceAll(',', '.')) ?? item.ganhosAdicionais;
    final novoGasto = double.tryParse(gastosController.text.replaceAll(',', '.')) ?? item.gastosTotais;
    
    // 🔥 CORRIGIDO: Calculando o saldo líquido real do fechamento para salvar corretamente
    final novoResto = (novoFixo + novoAdicional) - novoGasto;

    final atualizado = HistoricoMensal(
      mesAno: item.mesAno,
      ganhoFixo: novoFixo,
      ganhosAdicionais: novoAdicional,
      gastosTotais: novoGasto,
      resto: novoResto, // Vinculado matematicamente
    );

    await HistoricoService.atualizarMes(index, atualizado);
    await carregar();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registros de fechamento auditados com sucesso!"),
        backgroundColor: Color(0xFF0B1424),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00B4D8))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelectTab: widget.onSelectTab),
      body: FundoCosmico(
        child: SafeArea(
          child: carregando
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra Superior Executiva
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const Text(
                            "HISTÓRICO DE FECHAMENTOS",
                            style: TextStyle(
                              color: Color(0xFF00B4D8),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        "Arquivo Orbital",
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Relatórios consolidados de ciclos passados.",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Lista do Histórico Mensal
                      Expanded(
                        child: historico.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nenhum registro em arquivo de auditoria.",
                                  style: TextStyle(color: Colors.white38),
                                ),
                              )
                            : ListView.builder(
                                itemCount: historico.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final mes = historico[index];
                                  final positivo = mes.resto >= 0;
                                  
                                  // Paleta Neon Stitch UI para balanço
                                  final corBalanco = positivo ? const Color(0xFF8CE8FF) : const Color(0xFFFF6B6B);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B1424).withValues(alpha: 0.6), // Sintaxe moderna
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF1A2740)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            mes.mesAno,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            "R\$ ${mes.resto.toStringAsFixed(2)}",
                                            style: TextStyle(color: corBalanco, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "Fixo: R\$ ${mes.ganhoFixo.toStringAsFixed(2)}\n"
                                          "Extras: R\$ ${mes.ganhosAdicionais.toStringAsFixed(2)}\n"
                                          "Gastos: R\$ ${mes.gastosTotais.toStringAsFixed(2)}",
                                          style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4, fontFamily: 'monospace'),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF00B4D8), size: 28),
                                        onPressed: () => editarMes(index),
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