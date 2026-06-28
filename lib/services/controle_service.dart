import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/controle_financeiro.dart';
import '../models/historico_mensal.dart';
import 'preferences_service.dart';
import 'historico_service.dart';
import 'parcelas_service.dart';

class ControleService {
  static const String _key = 'controle_financeiro_key';

  static Future<ControleFinanceiro> carregarControle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return const ControleFinanceiro(
          receitasExtras: 0,
          despesas: 0,
          despesasPrevistas: 0,
        );
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return ControleFinanceiro.fromJson(decoded);
      }

      return const ControleFinanceiro(receitasExtras: 0, despesas: 0, despesasPrevistas: 0);
    } catch (e) {
      debugPrint("Erro ao decodificar controle financeiro (R8/ProGuard): $e");
      return const ControleFinanceiro(receitasExtras: 0, despesas: 0, despesasPrevistas: 0);
    }
  }

  static Future<void> salvarControle(ControleFinanceiro controle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(controle.toJson()));
    } catch (e) {
      debugPrint("Erro ao salvar controle financeiro: $e");
    }
  }

  // 💰 Sincronizado: Salva a receita extra e aumenta o saldo real da carteira
  static Future<void> adicionarReceita(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(receitasExtras: controle.receitasExtras + valor);
    await salvarControle(atualizado);

    final usuario = await PreferencesService.carregarUsuario();
    if (usuario != null) {
      await PreferencesService.atualizarSaldo(usuario.saldoAtual + valor);
    }
  }

  // 📉 Sincronizado: Salva a despesa e debita imediatamente do saldo real da carteira
  static Future<void> adicionarDespesa(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(despesas: controle.despesas + valor);
    await salvarControle(atualizado);

    final usuario = await PreferencesService.carregarUsuario();
    if (usuario != null) {
      await PreferencesService.atualizarSaldo(usuario.saldoAtual - valor);
    }
  }

  static Future<void> adicionarPrevisto(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(despesasPrevistas: controle.despesasPrevistas + valor);
    await salvarControle(atualizado);
  }

  static Future<bool> verificarEAtualizarViradaMes() async {
    return false; 
  }

  // 🚀 Virada de Ciclo Segura e Completa
  static Future<void> encerrarMes() async {
    try {
      final controle = await carregarControle();
      final usuario = await PreferencesService.carregarUsuario();
      final totalParcelasMes = await ParcelasService.calcularTotalMes();

      if (usuario == null) return;

      final dataAtual = DateTime.now();
      final mesAnoFormatado = "${dataAtual.month.toString().padLeft(2, '0')}/${dataAtual.year}";
      final gastosSomados = controle.despesas + totalParcelasMes;

      // 1. Gera o snapshot e salva no Histórico Visível
      final novoHistorico = HistoricoMensal(
        mesAno: mesAnoFormatado,
        ganhoFixo: usuario.ganhoFixo,
        ganhosAdicionais: controle.receitasExtras,
        gastosTotais: gastosSomados,
      );
      await HistoricoService.adicionar(novoHistorico);

      // 2. Avança as parcelas dos cartões de crédito (Muda de mês nativo)
      await ParcelasService.processarMes();

      // 3. Calcula o saldo inicial do mês seguinte
      final novoTotalParcelasProximoMes = await ParcelasService.calcularTotalMes();
      final novoSaldoCalculado = (usuario.saldoAtual + usuario.ganhoFixo) - novoTotalParcelasProximoMes;
      
      final usuarioAtualizado = usuario.copyWith(
        saldoAtual: novoSaldoCalculado,
        ultimoMesVerificado: dataAtual.month,
      );
      await PreferencesService.salvarUsuario(usuarioAtualizado);

      // 4. Limpa o painel do mês atual para folha zerada
      const controleResetado = ControleFinanceiro(
        receitasExtras: 0,
        despesas: 0,
        despesasPrevistas: 0,
      );
      await salvarControle(controleResetado);
    } catch (e) {
      debugPrint("Erro crítico durante o encerramento do mês: $e");
    }
  }
}