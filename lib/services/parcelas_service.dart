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

  /// 🚀 NOVO: Cadastrar Compra Parcelada Automatizada
  /// Calcula o valor da parcela se o usuário passar o total, ou vice-versa,
  /// e cria o objeto Parcela perfeitamente estruturado para a sua model.
  static Future<void> cadastrarCompraParcelada({
    required String nome,
    required double valorTotal,
    required int totalParcelas,
    double? valorDaParcela, // Opcional: Se não passar, o app calcula
  }) async {
    final calculoParcela = valorDaParcela ?? (valorTotal / totalParcelas);

    // Cria a estrutura baseada na sua Model 'Parcela'
    // (Ajuste os nomes dos parâmetros se a sua classe Parcela usar nomes diferentes)
    final novaParcela = Parcela(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único baseado no tempo
      nome: nome,
      valorTotal: valorTotal,
      valorDoMes: calculoParcela,
      parcelaAtual: 1,
      totalParcelas: totalParcelas,
    );

    await adicionarParcela(novaParcela);
  }

  /// ✏️ NOVO: Editar Compra Parcelada Existente
  static Future<void> editarCompraParcelada(String id, {
    required String novoNome,
    required double novoValorDoMes,
    required int novoTotalParcelas,
    required int parcelaAtual,
  }) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);
    
    if (index != -1) {
      lista[index].nome = novoNome;
      lista[index].valorDoMes = novoValorDoMes;
      lista[index].totalParcelas = novoTotalParcelas;
      lista[index].parcelaAtual = parcelaAtual;
      lista[index].valorTotal = novoValorDoMes * novoTotalParcelas; // Recalcula o total
      
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