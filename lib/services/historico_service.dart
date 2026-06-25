import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/historico_mensal.dart';

class HistoricoService {
  static const String _key = 'historico_financeiro_key';

  static Future<List<HistoricoMensal>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => HistoricoMensal.fromJson(item)).toList();
  }

  static Future<void> salvarLista(List<HistoricoMensal> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lista.map((item) => item.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> adicionar(HistoricoMensal novo) async {
    final lista = await carregar();
    lista.insert(0, novo); 
    await salvarLista(lista);
  }

  static Future<void> atualizarMes(int index, HistoricoMensal atualizado) async {
    final lista = await carregar();
    if (index >= 0 && index < lista.length) {
      lista[index] = atualizado;
      await salvarLista(lista);
    }
  }
}