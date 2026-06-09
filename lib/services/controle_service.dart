import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/controle_financeiro.dart';

class ControleService {
  static const String _key = 'controle_financeiro';

  static ControleFinanceiro? _cache;

  /// 🔄 carregar controle
  static Future<ControleFinanceiro> carregarControle() async {
    if (_cache != null) return _cache!;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) {
      _cache = const ControleFinanceiro(
        receitasExtras: 0,
        despesas: 0,
        despesasPrevistas: 0,
      );
      return _cache!;
    }

    final map = jsonDecode(data);

    _cache = ControleFinanceiro.fromMap(
      Map<String, dynamic>.from(map),
    );

    return _cache!;
  }

  /// 💾 salvar estado
  static Future<void> _salvar(ControleFinanceiro controle) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(controle.toMap()),
    );

    _cache = controle;
  }

  /// ➕ receita
  static Future<void> adicionarReceita(double valor) async {
    final atual = await carregarControle();

    final novo = atual.copyWith(
      receitasExtras: atual.receitasExtras + valor,
    );

    await _salvar(novo);
  }

  /// ➖ despesa
  static Future<void> adicionarDespesa(double valor) async {
    final atual = await carregarControle();

    final novo = atual.copyWith(
      despesas: atual.despesas + valor,
    );

    await _salvar(novo);
  }

  /// 📉 previsto
  static Future<void> adicionarPrevisto(double valor) async {
    final atual = await carregarControle();

    final novo = atual.copyWith(
      despesasPrevistas: atual.despesasPrevistas + valor,
    );

    await _salvar(novo);
  }

  /// 🔄 encerra mês (SEM reset automático invisível)
  static Future<ControleFinanceiro> encerrarMes() async {
    final atual = await carregarControle();

    final snapshot = atual;

    final reset = const ControleFinanceiro(
      receitasExtras: 0,
      despesas: 0,
      despesasPrevistas: 0,
    );

    await _salvar(reset);

    return snapshot; // 👈 importante para histórico
  }

  /// 📊 saldo atual
  static Future<double> getSaldo(double salarioBase) async {
    final controle = await carregarControle();
    return controle.saldoFinal(salarioBase);
  }

  /// 🧹 limpar cache
  static void limparCache() {
    _cache = null;
  }

  /// 🔁 update completo (avançado)
  static Future<void> atualizar(ControleFinanceiro novo) async {
    await _salvar(novo);
  }
}