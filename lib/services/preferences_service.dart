import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import 'historico_service.dart';
import 'parcelas_service.dart'; // Importado para realizar a limpeza física de cache no reset

class PreferencesService {
  static const String _keyUsuario = 'usuario_dados';
  static const String _cadastroFeito = 'cadastroFeito';

  // Chaves dos outros serviços para realizar a faxina completa de dados no reset de fábrica
  static const String _keyControle = 'controle_financeiro_dados';
  static const String _keyParcelas = 'parcelas';

  /// 💾 Salva o objeto Usuário completo convertido em JSON string de forma segura
  static Future<void> salvarUsuario(Usuario usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(usuario.toJson());
      await prefs.setString(_keyUsuario, jsonStr);
      await prefs.setBool(_cadastroFeito, true);
    } catch (e) {
      debugPrint("Erro crítico ao salvar usuário: $e");
    }
  }

  /// 🛰️ Carrega o usuário restaurando o estado exato de todas as variáveis
  static Future<Usuario?> carregarUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyUsuario);

      if (jsonStr == null || jsonStr.isEmpty) {
        debugPrint("Nenhum dado de usuário localizado no armazenamento local.");
        return null;
      }

      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return Usuario.fromJson(decoded);
      }
      
      return null;
    } catch (e) {
      debugPrint("Erro de Desserialização (R8/ProGuard) ao carregar usuário: $e");
      return null;
    }
  }

  /// 🔍 Verifica se o fluxo inicial de cadastro já foi realizado
  static Future<bool> cadastroExiste() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cadastroFeito) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// ✏️ Atualiza dinamicamente o ganho recorrente sem corromper os outros dados
  static Future<void> atualizarGanho(double ganho) async {
    final usuarioAtual = await carregarUsuario();
    if (usuarioAtual != null) {
      final usuarioAtualizado = usuarioAtual.copyWith(ganhoFixo: ganho);
      await salvarUsuario(usuarioAtualizado);
    }
  }

  /// ✏️ Atualiza dinamicamente o saldo real mantendo a consistência do app
  static Future<void> atualizarSaldo(double novoSaldo) async {
    final usuarioAtual = await carregarUsuario();
    if (usuarioAtual != null) {
      final usuarioAtualizado = usuarioAtual.copyWith(saldoAtual: novoSaldo);
      await salvarUsuario(usuarioAtualizado);
    }
  }

  /// 🧹 Remove o histórico mensal chamando a rotina encapsulada do serviço correspondente
  static Future<void> limparHistorico() async {
    await HistoricoService.limpar();
  }

  /// 🔄 Limpa o banco de dados local para o estado de fábrica de forma limpa e segura
  static Future<void> resetarAplicativo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Limpa os dados locais de controle do usuário
      await prefs.remove(_keyUsuario);
      await prefs.remove(_cadastroFeito);

      // 2. Aciona o método de limpeza próprio do serviço de históricos
      await HistoricoService.limpar();

      // 3. CORREÇÃO: Limpa os lançamentos diários e as compras parceladas ativas
      await prefs.remove(_keyControle);
      await prefs.remove(_keyParcelas);

      // 4. CORREÇÃO: Limpa a memória RAM (Cache) do serviço de parcelas para evitar ghost-renders
      ParcelasService.limparCache();
      
      debugPrint("Restauração de fábrica concluída com sucesso.");
    } catch (e) {
      debugPrint("Erro ao realizar reset de fábrica: $e");
    }
  }
}