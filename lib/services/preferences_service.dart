import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class PreferencesService {
  static const String _nome = 'nome';
  static const String _sobrenome = 'sobrenome';
  static const String _empresa = 'empresa';
  static const String _cargo = 'cargo';
  static const String _ganho = 'ganho';
  static const String _cadastroFeito = 'cadastroFeito';
  static const String _saldo = 'saldo_atual';
  static const String _ultimoMes = 'ultimo_mes_verificado';

  static Future<void> salvarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nome, usuario.nome);
    await prefs.setString(_sobrenome, usuario.sobrenome);
    await prefs.setString(_empresa, usuario.empresa);
    await prefs.setString(_cargo, usuario.cargo);
    await prefs.setDouble(_ganho, usuario.ganhoFixo);
    await prefs.setDouble(_saldo, usuario.saldoAtual);
    await prefs.setInt(_ultimoMes, usuario.ultimoMesVerificado);
    await prefs.setBool(_cadastroFeito, true);
  }

  static Future<Usuario?> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_nome);

    if (nome == null || nome.isEmpty) return null;

    return Usuario(
      nome: nome,
      sobrenome: prefs.getString(_sobrenome) ?? '',
      empresa: prefs.getString(_empresa) ?? '',
      cargo: prefs.getString(_cargo) ?? '',
      ganhoFixo: prefs.getDouble(_ganho) ?? 0,
      saldoAtual: prefs.getDouble(_saldo) ?? (prefs.getDouble(_ganho) ?? 0),
      ultimoMesVerificado: prefs.getInt(_ultimoMes) ?? DateTime.now().month,
    );
  }

  static Future<bool> cadastroExiste() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cadastroFeito) ?? false;
  }

  static Future<void> atualizarGanho(double ganho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ganho, ganho);
  }

  static Future<void> atualizarSaldo(double novoSaldo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_saldo, novoSaldo);
  }

  static Future<void> limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historicoMensal');
  }

  static Future<void> resetarAplicativo() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nome);
    await prefs.remove(_sobrenome);
    await prefs.remove(_empresa);
    await prefs.remove(_cargo);
    await prefs.remove(_ganho);
    await prefs.remove(_cadastroFeito);
    await prefs.remove(_saldo);
    await prefs.remove(_ultimoMes);
    await prefs.remove('historicoMensal');
  }
}