import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parcela.dart';

class ParcelasService {
  static const String _key = 'parcelas';
  static List<Parcela>? _cache;

  // 🪐 Otimizado: Só busca no disco se o cache local estiver vazio
  static Future<List<Parcela>> carregar() async {
    if (_cache != null) return _cache!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];

      final List<Parcela> listaValida = [];
      
      for (final item in data) {
        try {
          final Map<String, dynamic> map = jsonDecode(item) as Map<String, dynamic>;
          listaValida.add(Parcela.fromJson(map));
        } catch (innerError) {
          // Se uma única parcela der erro (R8/ProGuard), ignora ela e não quebra a lista toda
          debugPrint("Erro ao desserializar uma parcela individual: $innerError");
        }
      }

      _cache = listaValida;
      return _cache!;
    } catch (e) {
      debugPrint("Erro crítico ao carregar lista de parcelas: $e");
      return [];
    }
  }

  static Future<void> salvar(List<Parcela> lista) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> dadosMapeados = lista.map((e) => jsonEncode(e.toJson())).toList();
      
      await prefs.setStringList(_key, dadosMapeados);
      _cache = List.from(lista); // Sincroniza o cache imediatamente de forma segura
    } catch (e) {
      debugPrint("Erro ao salvar parcelas no SharedPreferences: $e");
    }
  }

  static Future<void> adicionarParcela(Parcela p) async {
    final lista = await carregar();
    lista.add(p);
    await salvar(lista);
  }

  static Future<List<Parcela>> carregarParcelas() async {
    return await carregar();
  }

  static Future<void> deletarParcelas(String id) async {
    final lista = await carregar();
    lista.removeWhere((p) => p.id == id);
    await salvar(lista);
  }

  static Future<void> salvarParcelas(Parcela nova) async {
    await adicionarParcela(nova);
  }

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

  // 📊 Vinculado à propriedade correta 'valorParcela' do seu modelo
  static Future<double> calcularTotalMes() async {
    final lista = await carregar();
    double total = 0;
    for (final p in lista) {
      if (p.ativa && p.parcelaAtual <= p.totalParcelas) {
        total += p.valorParcela;
      }
    }
    return total;
  }

  static Future<void> processarMes() async {
    final lista = await carregar();
    final List<Parcela> atualizada = [];
    
    for (final p in lista) {
      atualizada.add(p.avancarParcela());
    }

    await salvar(atualizada);
  }

  static Future<void> adiantarContrato(String id) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);
    if (index != -1) {
      lista[index] = lista[index].adiantar();
      await salvar(lista);
    }
  }

  static Future<void> atrasarContrato(String id) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);
    if (index != -1) {
      lista[index] = lista[index].atrasar();
      await salvar(lista);
    }
  }

  static void limparCache() {
    _cache = null;
  }
}