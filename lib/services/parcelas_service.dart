import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parcela.dart';

class ParcelasService {
  static const String _key = 'parcelas';
  static List<Parcela>? _cache;

  /// 🔄 carregar parcelas (Interno)
  static Future<List<Parcela>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    _cache = data
        .map((e) => Parcela.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    return _cache!;
  }

  /// 💾 salvar lista (Interno)
  static Future<void> salvar(List<Parcela> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      lista.map((e) => jsonEncode(e.toJson())).toList(),
    );
    _cache = List.from(lista);
  }

  /// ➕ adicionar parcela individual
  static Future<void> adicionarParcela(Parcela p) async {
    final lista = await carregar();
    lista.add(p);
    await salvar(lista);
  }

  // ==========================================
  // 🔥 PONTES DE CONEXÃO COM A PARCELAS_PAGE
  // ==========================================

  /// 📡 Linha 29: Método esperado pela página para carregar os dados
  static Future<List<Parcela>> carregarParcelas() async {
    return await carregar();
  }

  /// 🗑️ Linha 38: Método esperado pela página para deletar uma parcela
  static Future<void> deletarParcelas(String id) async {
    final lista = await carregar();
    lista.removeWhere((p) => p.id == id);
    await salvar(lista);
  }

  /// 💾 Linha 116: Método esperado pela página para salvar uma nova parcela
  static Future<void> salvarParcelas(Parcela nova) async {
    await adicionarParcela(nova);
  }

  // ==========================================

  /// 🚀 Cadastrar Compra Parcelada Automatizada
  static Future<void> cadastrarCompraParcelada({
    required String descricao,
    required double valorTotal,
    required int totalParcelas,
    double? valorDaParcela,
  }) async {
    final calculoParcela = valorDaParcela ?? (valorTotal / totalParcelas);

    final novaParcela = Parcela(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descricao: descricao,
      valorTotal: valorTotal,
      valorParcela: calculoParcela,
      parcelaAtual: 1,
      ativa: true,
      totalParcelas: totalParcelas,
    );

    await adicionarParcela(novaParcela);
  }

  /// ✏️ Editar Compra Parcelada Existente
  static Future<void> editarCompraParcelada(
    String id, {
    required String novaDescricao,
    required double novoValorParcela,
    required int novoTotalParcelas,
    required int parcelaAtual,
  }) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);

    if (index != -1) {
      final p = lista[index];
      lista[index] = p.copyWith(
        descricao: novaDescricao,
        valorParcela: novoValorParcela,
        totalParcelas: novoTotalParcelas,
        parcelaAtual: parcelaAtual,
        valorTotal: novoValorParcela * novoTotalParcelas,
        ativa: parcelaAtual <= novoTotalParcelas,
      );
      await salvar(lista);
    }
  }

  /// 📊 calcula total do mês SEM alterar estado
  static Future<double> calcularTotalMes() async {
    final lista = await carregar();
    double total = 0;
    for (final p in lista) {
      if (p.parcelaAtual <= p.totalParcelas) {
        total += p.valorDoMes;
      }
    }
    return total;
  }

  /// 🔄 avança parcelas (EXECUÇÃO CONTROLADA)
  static Future<void> processarMes() async {
    final lista = await carregar();
    final List<Parcela> atualizada = [];
    
    for (final p in lista) {
      atualizada.add(p.avancarParcela());
    }

    await salvar(atualizada);
  }

  /// 🧹 limpar cache
  static void limparCache() {
    _cache = null;
  }
}