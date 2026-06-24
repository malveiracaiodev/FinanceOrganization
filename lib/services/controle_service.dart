import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/controle_financeiro.dart';
import '../models/historico_mensal.dart';
import 'preferences_service.dart';
import 'historico_service.dart';
import 'parcelas_service.dart'; // 🔥 Importação do motor de parcelas integrada

class ControleService {
  static const String _key = 'controle_financeiro_key';

  // 📥 Carrega os dados do controle financeiro do mês atual
  static Future<ControleFinanceiro> carregarControle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return ControleFinanceiro(
        receitasExtras: 0,
        despesas: 0,
        despesasPrevistas: 0,
      );
    }

    return ControleFinanceiro.fromJson(jsonDecode(jsonString));
  }

  // 💾 Salva o estado do mês atual
  static Future<void> salvarControle(ControleFinanceiro controle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(controle.toJson()));
  }

  // 🟢 Adiciona uma receita extra
  static Future<void> adicionarReceita(double valor) async {
    final controle = await carregarControle();
    controle.receitasExtras += valor;
    await salvarControle(controle);
  }

  // 🔴 Adiciona uma despesa diária
  static Future<void> adicionarDespesa(double valor) async {
    final controle = await carregarControle();
    controle.despesas += valor;
    await salvarControle(controle);
  }

  // 🟡 Adiciona uma despesa prevista
  static Future<void> adicionarPrevisto(double valor) async {
    final controle = await carregarControle();
    controle.despesasPrevistas += valor;
    await salvarControle(controle);
  }

  // 🚀 Compila os dados correntes, inclui as parcelas e encerra a órbita do mês
  static Future<void> encerrarMes() async {
    final controle = await carregarControle();
    final usuario = await PreferencesService.carregarUsuario();
    
    // 🔥 Captura as parcelas vigentes no exato momento do fechamento
    final totalParcelasMes = await ParcelasService.calcularTotalMes();

    if (usuario == null) return;

    // Formata o marcador temporal do fechamento (Ex: "06/2026")
    final dataAtual = DateTime.now();
    final mesAnoFormatado = "${dataAtual.month.toString().padLeft(2, '0')}/${dataAtual.year}";

    // Agrupa os gastos reais (Despesas do dia + a fatura do cartão parcelado)
    final gastosSomados = controle.despesas + totalParcelasMes;

    // Instancia o modelo de histórico unificado
    final novoHistorico = HistoricoMensal(
      mesAno: mesAnoFormatado,
      ganhoFixo: usuario.ganhoFixo,
      ganhosAdicionais: controle.receitasExtras,
      gastosTotais: gastosSomados,
    );

    // Envia para o arquivo histórico persistente
    await HistoricoService.adicionar(novoHistorico);

    // Zera os dados do mês atual para iniciar o novo ciclo operacional
    final controleResetado = ControleFinanceiro(
      receitasExtras: 0,
      despesas: 0,
      despesasPrevistas: 0,
    );
    
    await salvarControle(controleResetado);
  }
}