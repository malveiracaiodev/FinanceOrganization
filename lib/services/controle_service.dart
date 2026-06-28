import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/controle_financeiro.dart';
import '../models/historico_mensal.dart';
import 'historico_service.dart';
import 'parcelas_service.dart';
import 'preferences_service.dart';

class ControleService {
  static const String _keyControle = 'controle_financeiro_dados';

  /// 🛰️ Carrega os dados do ciclo atual salvos no SharedPreferences
  static Future<ControleFinanceiro> carregarControle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyControle);
    if (jsonStr == null) {
      // Se não existir, inicializa o sistema limpo
      return const ControleFinanceiro(receitasExtras: 0.0, despesas: 0.0);
    }
    return ControleFinanceiro.fromJson(jsonDecode(jsonStr));
  }

  /// 💾 Salva o estado atual no disco local
  static Future<void> _salvarControle(ControleFinanceiro controle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyControle, jsonEncode(controle.toJson()));
  }

  /// 🟢 Injeta um ganho extra ao ciclo corrente
  static Future<void> adicionarReceita(double valor) async {
    final atual = await carregarControle();
    final atualizado = atual.copyWith(receitasExtras: atual.receitasExtras + valor);
    await _salvarControle(atualizado);
  }

  /// 🔴 Registra uma despesa imediata à vista
  static Future<void> adicionarDespesa(double valor) async {
    final atual = await carregarControle();
    final updated = atual.copyWith(despesas: atual.despesas + valor);
    await _salvarControle(updated);
  }

  /// 🔄 PROMOVER VIRADA DE CICLO (Encerra o mês cronológico)
  static Future<void> encerrarMes() async {
    final usuario = await PreferencesService.carregarUsuario();
    final atual = await carregarControle();
    
    // Calcula as parcelas do mês atual para embutir no fechamento histórico
    final totalParcelasMes = await ParcelasService.calcularTotalMes();
    final ganhoFixo = usuario?.ganhoFixo ?? 0.0;
    
    // Define o nome do mês anterior baseado no momento do clique
    final agora = DateTime.now();
    final mesesNomes = [
      "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ];
    final stringMesAno = "${mesesNomes[agora.month - 1]} ${agora.year}";

    final totalGastosCiclo = atual.despesas + totalParcelasMes;
    final saldoRestante = (ganhoFixo + atual.receitasExtras) - totalGastosCiclo;

    // 📦 1. Cria o Snapshot para o Histórico (Chamando o método correto 'adicionar')
    final novoHistorico = HistoricoMensal(
      mesAno: stringMesAno,
      ganhoFixo: ganhoFixo,
      ganhosAdicionais: atual.receitasExtras,
      gastosTotais: totalGastosCiclo,
    );

    await HistoricoService.adicionar(novoHistorico);

    // 💳 2. Roda a fatura e avança o contador de todos os parcelamentos ativos (Chamando 'virarMes')
    await ParcelasService.virarMes();

    // 🧹 3. Limpa a folha mensal mantendo o sistema pronto para o novo ciclo
    const controleZerado = ControleFinanceiro(receitasExtras: 0.0, despesas: 0.0);
    await _salvarControle(controleZerado);

    // 👤 4. Atualiza o marcador do último mês verificado no perfil do usuário
    if (usuario != null) {
      final proxMes = agora.month == 12 ? 1 : agora.month + 1;
      final usuarioAtualizado = usuario.copyWith(
        ultimoMesVerificado: proxMes,
        saldoAtual: saldoRestante, // O saldo que sobrou passa a acumular
      );
      await PreferencesService.salvarUsuario(usuarioAtualizado);
    }
  }
}