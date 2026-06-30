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
      return const ControleFinanceiro(receitasExtras: 0.0, despesas: 0.0);
    }
    return ControleFinanceiro.fromJson(jsonDecode(jsonStr));
  }

  /// 💾 Salva o estado atual no disco local
  static Future<void> _salvarControle(ControleFinanceiro controle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyControle, jsonEncode(controle.toJson()));
  }

  /// 🟢 Injeta um ganho extra ao ciclo corrente e atualiza o saldo real imediatamente
  static Future<void> adicionarReceita(double valor) async {
    final atual = await carregarControle();
    final atualizado = atual.copyWith(receitasExtras: atual.receitasExtras + valor);
    await _salvarControle(atualizado);

    // CORREÇÃO: Atualiza o saldo do usuário em tempo real para a Dashboard atualizar
    final usuario = await PreferencesService.carregarUsuario();
    if (usuario != null) {
      final usuarioAtualizado = usuario.copyWith(
        saldoAtual: usuario.saldoAtual + valor,
      );
      await PreferencesService.salvarUsuario(usuarioAtualizado);
    }
  }

  /// 🔴 Registra uma despesa à vista e deduz do saldo real imediatamente
  static Future<void> adicionarDespesa(double valor) async {
    final atual = await carregarControle();
    final updated = atual.copyWith(despesas: atual.despesas + valor);
    await _salvarControle(updated);

    // CORREÇÃO: Atualiza o saldo do usuário em tempo real para a Dashboard atualizar
    final usuario = await PreferencesService.carregarUsuario();
    if (usuario != null) {
      final usuarioAtualizado = usuario.copyWith(
        saldoAtual: usuario.saldoAtual - valor,
      );
      await PreferencesService.salvarUsuario(usuarioAtualizado);
    }
  }

  /// 🔄 PROMOVER VIRADA DE CICLO (Encerra o mês cronológico)
  static Future<void> encerrarMes() async {
    final usuario = await PreferencesService.carregarUsuario();
    final atual = await carregarControle();
    
    // Calcula as parcelas do mês atual para embutir no fechamento histórico
    final totalParcelasMes = await ParcelasService.calcularTotalMes();
    final ganhoFixo = usuario?.ganhoFixo ?? 0.0;
    
    // Define os nomes dos meses
    final mesesNomes = [
      "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ];

    final agora = DateTime.now();
    
    // CORREÇÃO: Usa o mês sendo verificado no perfil (e não a data do clique)
    final cicloMes = usuario?.ultimoMesVerificado ?? agora.month;
    
    // Caso o usuário feche dezembro em janeiro, ajusta o ano para o ano anterior
    int cicloAno = agora.year;
    if (agora.month == 1 && cicloMes == 12) {
      cicloAno = agora.year - 1;
    }
    
    final stringMesAno = "${mesesNomes[cicloMes - 1]} $cicloAno";

    // Soma das saídas (despesas normais + faturas de parcelamento do ciclo)
    final totalGastosCiclo = atual.despesas + totalParcelasMes;
    
    // Calcula o que sobrou exclusivamente do ciclo atual
    final saldoRestante = (ganhoFixo + atual.receitasExtras) - totalGastosCiclo;

    // 📦 1. Cria o Snapshot para o Histórico Mensal
    // Nota: Lembre-se de certificar que o seu modelo 'HistoricoMensal' possui esses campos no construtor
    final novoHistorico = HistoricoMensal(
      mesAno: stringMesAno,
      ganhoFixo: ganhoFixo,
      ganhosAdicionais: atual.receitasExtras,
      gastosTotais: totalGastosCiclo,
    );

    await HistoricoService.adicionar(novoHistorico);

    // 💳 2. Roda a fatura e avança o contador de todos os parcelamentos ativos
    await ParcelasService.virarMes();

    // 🧹 3. Limpa a folha mensal mantendo o sistema pronto para o novo ciclo
    const controleZerado = ControleFinanceiro(receitasExtras: 0.0, despesas: 0.0);
    await _salvarControle(controleZerado);

    // 👤 4. Atualiza o marcador do último mês verificado no perfil do usuário e injeta o novo salário
    if (usuario != null) {
      final proxMes = usuario.ultimoMesVerificado == 12 ? 1 : usuario.ultimoMesVerificado + 1;
      
      // CORREÇÃO: O saldo acumulado recebe a sobra do ciclo anterior + o novo salário recorrente
      final novoSaldoInicial = saldoRestante + ganhoFixo;

      final usuarioAtualizado = usuario.copyWith(
        ultimoMesVerificado: proxMes,
        saldoAtual: novoSaldoInicial,
      );
      
      await PreferencesService.salvarUsuario(usuarioAtualizado);
    }
  }
}