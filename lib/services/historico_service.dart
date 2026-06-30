import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/historico_mensal.dart';

class HistoricoService {
  // Mantida privada para encapsulamento das responsabilidades de persistência
  static const String _keyHistorico = 'historico_financeiro_key';

  /// 🛰️ Carrega todos os registros do histórico mensal salvos localmente
  static Future<List<HistoricoMensal>> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyHistorico);

      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<HistoricoMensal> listaValida = [];

      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            listaValida.add(HistoricoMensal.fromJson(item));
          }
        } catch (innerError) {
          // Evita que falhas isoladas de mapeamento travem toda a renderização da lista
          debugPrint("Erro ao decodificar registro mensal específico: $innerError");
        }
      }

      return listaValida;
    } catch (e) {
      debugPrint("Erro crítico ao carregar histórico financeiro total: $e");
      return [];
    }
  }

  /// 💾 Salva a lista inteira de fechamentos históricos no disco local
  static Future<void> salvarLista(List<HistoricoMensal> lista) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(lista.map((item) => item.toJson()).toList());
      await prefs.setString(_keyHistorico, jsonString);
    } catch (e) {
      debugPrint("Erro ao salvar lista de histórico: $e");
    }
  }

  /// 📥 Adiciona um novo fechamento de ciclo e previne registros duplicados
  static Future<void> adicionar(HistoricoMensal novo) async {
    final lista = await carregar();
    
    // CORREÇÃO: Remove duplicados com o mesmo mês e ano antes de inserir para evitar duplicatas de cliques acidentais
    lista.removeWhere((item) => item.mesAno.trim().toLowerCase() == novo.mesAno.trim().toLowerCase());
    
    lista.insert(0, novo); // Mantém o mês mais recente no topo (Index 0)
    await salvarLista(lista);
  }

  /// ✏️ Atualiza as informações de um mês específico
  static Future<void> atualizarMes(int index, HistoricoMensal updated) async {
    final lista = await carregar();
    if (index >= 0 && index < lista.length) {
      lista[index] = updated;
      await salvarLista(lista);
    }
  }

  /// ❌ REMOVIDO: Método para deletar um mês específico por index (CRUD completo)
  static Future<void> removerMes(int index) async {
    final lista = await carregar();
    if (index >= 0 && index < lista.length) {
      lista.removeAt(index);
      await salvarLista(lista);
    }
  }

  /// 🧹 Método público de limpeza (Substitui a necessidade de exportar a chave secreta)
  static Future<void> limpar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHistorico);
    } catch (e) {
      debugPrint("Erro ao limpar dados de histórico: $e");
    }
  }
}