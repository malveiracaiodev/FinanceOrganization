import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parcela.dart';

class ParcelasService {
  static const String _key = 'parcelas';
  static List<Parcela>? _cache;

  /// 🛰️ Carrega a lista de parcelas utilizando cache para otimização de I/O
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
          // Proteção contra falhas de desserialização individuais
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

  /// 💾 Salva o estado atual das parcelas e sincroniza o cache imediatamente
  static Future<void> salvar(List<Parcela> lista) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> dadosMapeados = lista.map((e) => jsonEncode(e.toJson())).toList();
      
      await prefs.setStringList(_key, dadosMapeados);
      _cache = List.from(lista); // Clone de segurança para sincronizar o cache em memória
    } catch (e) {
      debugPrint("Erro ao salvar parcelas no SharedPreferences: $e");
    }
  }

  /// 📥 Adiciona uma nova parcela diretamente à lista e salva
  static Future<void> adicionarParcela(Parcela p) async {
    final lista = await carregar();
    lista.add(p);
    await salvar(lista);
  }

  /// ❌ Deleta um parcelamento específico usando o ID único
  static Future<void> deletarParcelas(String id) async {
    final lista = await carregar();
    lista.removeWhere((p) => p.id == id);
    await salvar(lista);
  }

  /// 📝 Cria e cadastra uma compra parcelada de forma padronizada
  static Future<void> cadastrarCompraParcelada({
    required String descricao,
    required double valorTotal,
    required int totalParcelas,
    double? valorDaParcela,
  }) async {
    // Caso não seja passado o valor individual, faz a divisão simples das parcelas
    final calculoParcela = valorDaParcela ?? (valorTotal / totalParcelas);

    final novaParcela = Parcela(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único baseado em timestamp
      descricao: descricao,
      valorTotal: valorTotal,
      valorParcela: calculoParcela,
      parcelaAtual: 1,
      ativa: true,
      totalParcelas: totalParcelas,
    );

    await adicionarParcela(novaParcela);
  }

  /// ✏️ Edita os parâmetros de um contrato de parcelamento existente
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
        // Desativa o parcelamento automaticamente caso o limite de parcelas seja atingido
        ativa: parcelaAtual <= novoTotalParcelas,
      );
      await salvar(lista);
    }
  }

  /// 📊 Calcula o somatório total das faturas de parcelamentos ativos do mês corrente
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

  /// 🔄 Avança o contador de parcelamento de todos os contratos ativos (Fechamento Mensal)
  static Future<void> processarMes() async {
    final lista = await carregar();
    final List<Parcela> atualizada = [];
    
    for (final p in lista) {
      atualizada.add(p.avancarParcela());
    }

    await salvar(atualizada);
  }

  /// 🔄 Alias tático para integração e fechamento no ControleService
  static Future<void> virarMes() async {
    await processarMes();
  }

  /// ⏭️ Avança manualmente o andamento de um parcelamento específico
  static Future<void> adiantarContrato(String id) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);
    if (index != -1) {
      lista[index] = lista[index].adiantar();
      await salvar(lista);
    }
  }

  /// ⏮️ Retrocede manualmente o andamento de um parcelamento específico
  static Future<void> atrasarContrato(String id) async {
    final lista = await carregar();
    final index = lista.indexWhere((p) => p.id == id);
    if (index != -1) {
      lista[index] = lista[index].atrasar();
      await salvar(lista);
    }
  }

  /// 🧹 Limpa o cache de memória do sistema (Ex: Caso ocorra logout ou reset de perfil)
  static void limparCache() {
    _cache = null;
  }
}