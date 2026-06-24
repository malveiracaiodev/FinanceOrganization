import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parcela.dart';

class ParcelasService {
  static const _key = 'parcelas';
  static List<Parcela>? _cache;

  /// 🔄 carregar parcelas
  static Future<List<Parcela>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    _cache = data
        .map((e) => Parcela.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();

    return _cache!;
  }

  /// 💾 salvar lista
  static Future<void> salvar(List<Parcela> lista) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      lista.map((e) => jsonEncode(e.toMap())).toList(),
    );

    _cache = List.from(lista);
  }

  /// ➕ adicionar parcela individual (Mantido original)
  static Future<void> adicionarParcela(Parcela p) async {
    final lista = await carregar();
    lista.add(p);
    await salvar(lista);
  }

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
  static Future<void> editarCompraParcelada(String id, {
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

  /// 🗑️ NOVO: Deletar ou quitar parcelamento
  static Future<void> removerCompraParcelada(String id) async {
    final lista = await carregar();
    lista.removeWhere((p) => p.id == id);
    await salvar(lista);
  }

  /// 📊 calcula total do mês SEM alterar estado (Mantido original)
  static Future<double> calcularTotalMes() async {
    final lista = await carregar();
    double total = 0;
    for (final p in lista) {
      // Se o parcelamento já acabou, não soma no mês atual
      if (p.parcelaAtual <= p.totalParcelas) {
        total += p.valorDoMes;
      }
    }
    return total;
  }

  /// 🔄 avança parcelas (EXECUÇÃO CONTROLADA - Mantido original)
  /// Modificado levemente apenas para não passar do limite de parcelas
  static Future<void> processarMes() async {
    final lista = await carregar();

    for (final p in lista) {
      if (p.parcelaAtual < p.totalParcelas) {
        p.avancarParcela(); // Método que você já criou na sua model
      } else {
        // Se já chegou na última parcela, podemos manter marcada ou remover. 
        // O ideal é manter para o histórico da Mark I, ou incrementar para p.parcelaAtual++
        p.avancarParcela(); 
      }
    }

    await salvar(lista);
  }

  /// 🧹 limpar cache (Mantido original)
  static void limparCache() {
    _cache = null;
  }
}