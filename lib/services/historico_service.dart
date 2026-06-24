import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/historico_mensal.dart';
import '../models/controle_financeiro.dart';
import 'parcelas_service.dart'; // 🔥 Importado para calcular o impacto no fechamento

class HistoricoService {
  static const String _key = 'historicoMensal';
  static List<HistoricoMensal>? _cache;

  /// 🔄 carregar histórico
  static Future<List<HistoricoMensal>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    _cache = data
        .map((e) => HistoricoMensal.fromMap(
              Map<String, dynamic>.from(jsonDecode(e)),
            ))
        .toList();

    return _cache!;
  }

  /// 💾 salvar
  static Future<void> _salvar(List<HistoricoMensal> lista) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      lista.map((e) => jsonEncode(e.toMap())).toList(),
    );

    _cache = List.from(lista);
  }

  /// ➕ adicionar mês (com proteção)
  static Future<void> adicionarMes(HistoricoMensal mes) async {
    final lista = await carregar();
    final existe = lista.any((e) => e.mesAno == mes.mesAno);

    if (existe) return;

    lista.add(mes);
    await _salvar(lista);
  }

  /// ✏️ atualizar mês por índice seguro
  static Future<void> atualizarMes(int index, HistoricoMensal novo) async {
    final lista = await carregar();

    if (index < 0 || index >= lista.length) return;

    lista[index] = novo;
    await _salvar(lista);
  }

  /// 🧠 atualizar por mês (seguro - Ideal para suas edições)
  static Future<void> atualizarPorMes(
    String mesAno,
    HistoricoMensal novo,
  ) async {
    final lista = await carregar();
    final index = lista.indexWhere((e) => e.mesAno == mesAno);

    if (index == -1) return;

    lista[index] = novo;
    await _salvar(lista);
  }

  /// 🔄 remover mês
  static Future<void> removerMes(String mesAno) async {
    final lista = await carregar();

    lista.removeWhere((e) => e.mesAno == mesAno);
    await _salvar(lista);
  }

  /// 📊 fechar mês (IDEMPOTENTE - Chamado manualmente se necessário)
  static Future<void> encerrarMes({
    required String mesAno,
    required ControleFinanceiro controle,
    required double salarioBase,
  }) async {
    final lista = await carregar();
    final jaExiste = lista.any((e) => e.mesAno == mesAno);

    if (jaExiste) return;

    // 🔥 Puxa o total de parcelas que rodaram no mês para compor os gastos totais reais
    final totalParcelas = await ParcelasService.calcularTotalMes();

    final novoMes = HistoricoMensal(
      mesAno: mesAno,
      ganhoFixo: salarioBase,
      ganhosAdicionais: controle.receitasExtras,
      gastosTotais: controle.despesas + controle.despesasPrevistas + totalParcelas,
    );

    lista.add(novoMes);
    await _salvar(lista);
  }

  /// 🌉 PONTE: Salvar no Histórico via Virada de Mês Automatizada
  /// Converte 'mes' e 'ano' de inteiros para String 'MM/YYYY' e puxa o salário base do usuário
  static Future<void> salvarNoHistorico({
    required int mes,
    required int ano,
    required ControleFinanceiro dados,
  }) async {
    // Formata o mês com 2 dígitos (Ex: 6 vira "06")
    final String mesFormatado = mes.toString().padLeft(2, '0');
    final String mesAnoChave = "$mesFormatado/$ano";

    // Puxamos o usuário para saber qual era o salário base desse fechamento
    final prefs = await SharedPreferences.getInstance();
    final double salarioBase = prefs.getDouble('ganho') ?? 0;

    await encerrarMes(
      mesAno: mesAnoChave,
      controle: dados,
      salarioBase: salarioBase,
    );
  }

  /// 🧹 limpar cache
  static void limparCache() {
    _cache = null;
  }
}