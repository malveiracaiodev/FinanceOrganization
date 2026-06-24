import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/historico_mensal.dart';

class HistoricoService {
  static const String _key = 'historico_financeiro_key';

  // 📂 Carrega a lista completa de históricos salvos
  static Future<List<HistoricoMensal>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => HistoricoMensal.fromJson(item)).toList();
  }

  // 💾 Salva a lista completa de volta no SharedPreferences
  static Future<void> salvarLista(List<HistoricoMensal> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lista.map((item) => item.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // ➕ Adiciona um novo fechamento ao topo do histórico
  static Future<void> adicionar(HistoricoMensal novo) async {
    final lista = await carregar();
    lista.insert(0, novo); // Adiciona o mês mais recente no topo da lista
    await salvarLista(lista);
  }

  // 🔥 Método crucial de sincronização para a HistoricoPage editar via índice
  static Future<void> atualizarMes(int index, HistoricoMensal atualizado) async {
    final lista = await carregar();
    if (index >= 0 && index < lista.length) {
      lista[index] = atualizado;
      await salvarLista(lista);
    }
  }
}