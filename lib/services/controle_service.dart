import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/controle_financeiro.dart';
import '../models/historico_mensal.dart';
import 'preferences_service.dart';
import 'historico_service.dart';
import 'parcelas_service.dart';

class ControleService {
  static const String _key = 'controle_financeiro_key';

  static Future<ControleFinanceiro> carregarControle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return const ControleFinanceiro(
        receitasExtras: 0,
        despesas: 0,
        despesasPrevistas: 0,
      );
    }

    return ControleFinanceiro.fromJson(jsonDecode(jsonString));
  }

  static Future<void> salvarControle(ControleFinanceiro controle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(controle.toJson()));
  }

  static Future<void> adicionarReceita(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(receitasExtras: controle.receitasExtras + valor);
    await salvarControle(atualizado);
  }

  static Future<void> adicionarDespesa(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(despesas: controle.despesas + valor);
    await salvarControle(atualizado);
  }

  static Future<void> adicionarPrevisto(double valor) async {
    final controle = await carregarControle();
    final atualizado = controle.copyWith(despesasPrevistas: controle.despesasPrevistas + valor);
    await salvarControle(atualizado);
  }

  static Future<bool> verificarEAtualizarViradaMes() async {
    // Implementação pendente para automação de ciclo via SharedPreferences se necessário
    return false; 
  }

  static Future<void> encerarMes() async {
    final controle = await carregarControle();
    final usuario = await PreferencesService.carregarUsuario();
    final totalParcelasMes = await ParcelasService.calcularTotalMes();

    if (usuario == null) return;

    final dataAtual = DateTime.now();
    final mesAnoFormatado = "${dataAtual.month.toString().padLeft(2, '0')}/${dataAtual.year}";
    final gastosSomados = controle.despesas + totalParcelasMes;

    final novoHistorico = HistoricoMensal(
      mesAno: mesAnoFormatado,
      ganhoFixo: usuario.ganhoFixo,
      ganhosAdicionais: controle.receitasExtras,
      gastosTotais: gastosSomados,
    );

    await HistoricoService.adicionar(novoHistorico);

    const controleResetado = ControleFinanceiro(
      receitasExtras: 0,
      despesas: 0,
      despesasPrevistas: 0,
    );
    
    await salvarControle(controleResetado);
  }
}