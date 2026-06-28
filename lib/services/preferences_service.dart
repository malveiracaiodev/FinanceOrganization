import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import 'historico_service.dart';

class PreferencesService {
  static const String _keyUsuario = 'usuario_dados';
  static const String _cadastroFeito = 'cadastroFeito';

  // Salva o objeto Usuário completo convertido em JSON string de forma segura
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

  // Carrega o usuário restaurando o estado exato de todas as variáveis
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

  static Future<bool> cadastroExiste() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cadastroFeito) ?? false;
    } catch (_) {
      return false;
    }
  }

  // Atualiza dinamicamente o ganho sem corromper os outros dados
  static Future<void> atualizarGanho(double ganho) async {
    final usuarioAtual = await carregarUsuario();
    if (usuarioAtual != null) {
      final usuarioAtualizado = usuarioAtual.copyWith(ganhoFixo: ganho);
      await salvarUsuario(usuarioAtualizado);
    }
  }

  // Atualiza dinamicamente o saldo real mantendo a consistência do app
  static Future<void> atualizarSaldo(double novoSaldo) async {
    final usuarioAtual = await carregarUsuario();
    if (usuarioAtual != null) {
      final usuarioAtualizado = usuarioAtual.copyWith(saldoAtual: novoSaldo);
      await salvarUsuario(usuarioAtualizado);
    }
  }

  // Remove o histórico mensal usando a chave correta e centralizada
  static Future<void> limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(HistoricoService.keyHistorico);
  }

  // Limpa o banco para o estado de fábrica de forma limpa e segura
  static Future<void> resetarAplicativo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
    await prefs.remove(_cadastroFeito);
    await prefs.remove(HistoricoService.keyHistorico);
  }
}