import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/historico_mensal.dart';

class HistoricoService {
  // 🔥 Tornada pública (sem o _) para que o PreferencesService possa usar a mesma chave de forma segura
  static const String keyHistorico = 'historico_financeiro_key';

  static Future<List<HistoricoMensal>> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(keyHistorico);

      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<HistoricoMensal> listaValida = [];

      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            listaValida.add(HistoricoMensal.fromJson(item));
          }
        } catch (innerError) {
          // Evita que uma falha de desserialização (R8/ProGuard) em um mês derrube todo o histórico
          debugPrint("Erro ao decodificar um registro mensal individual: $innerError");
        }
      }

      return listaValida;
    } catch (e) {
      debugPrint("Erro crítico ao carregar histórico financeiro total: $e");
      return [];
    }
  }

  static Future<void> salvarLista(List<HistoricoMensal> lista) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(lista.map((item) => item.toJson()).toList());
      await prefs.setString(keyHistorico, jsonString);
    } catch (e) {
      debugPrint("Erro ao salvar lista de histórico: $e");
    }
  }

  static Future<void> adicionar(HistoricoMensal novo) async {
    final lista = await carregar();
    lista.insert(0, novo); // Mantém o mês atualizado no topo da lista
    await salvarLista(lista);
  }

  static Future<void> atualizarMes(int index, HistoricoMensal updated) async {
    final lista = await carregar();
    if (index >= 0 && index < lista.length) {
      lista[index] = updated;
      await salvarLista(lista);
    }
  }
}