import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/historico_mensal.dart';

class HistoricoService {
  // 🔥 Tornada pública (sem o _) para que o PreferencesService possa usar a mesma chave de forma segura
  static const String keyHistorico = 'historico_financeiro_key';

  static Future<List<HistoricoMensal>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyHistorico);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => HistoricoMensal.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Erro ao decodificar histórico financeiro: $e");
      return [];
    }
  }

  static Future<void> salvarLista(List<HistoricoMensal> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lista.map((item) => item.toJson()).toList());
    await prefs.setString(keyHistorico, jsonString);
  }

  static Future<void> adicionar(HistoricoMensal novo) async {
    final lista = await carregar();
    lista.insert(0, novo); // Mantém o mês atualizado no topo da lista
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