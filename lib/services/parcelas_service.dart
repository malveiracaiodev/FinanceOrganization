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

  /// ➕ adicionar parcela
  static Future<void> adicionarParcela(Parcela p) async {
    final lista = await carregar();
    lista.add(p);
    await salvar(lista);
  }

  /// 📊 calcula total do mês SEM alterar estado
  static Future<double> calcularTotalMes() async {
    final lista = await carregar();

    double total = 0;

    for (final p in lista) {
      total += p.valorDoMes;
    }

    return total;
  }

  /// 🔄 avança parcelas (EXECUÇÃO CONTROLADA)
  static Future<void> processarMes() async {
    final lista = await carregar();

    for (final p in lista) {
      p.avancarParcela();
    }

    await salvar(lista);
  }

  /// 🧹 limpar cache
  static void limparCache() {
    _cache = null;
  }
}