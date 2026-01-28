// lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_drawer.dart';
import 'fundo_cosmico.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, dynamic>> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString('nome') ?? '',
      'sobrenome': prefs.getString('sobrenome') ?? '',
      'empresa': prefs.getString('empresa') ?? '',
      'cargo': prefs.getString('cargo') ?? '',
      'ganho': prefs.getDouble('ganho') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: FutureBuilder<Map<String, dynamic>>(
          future: carregarDados(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final dados = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Olá, ${dados['nome']} ${dados['sobrenome']}",
                  style: const TextStyle(color: Colors.cyan, fontSize: 22),
                ),
                Text(
                  "${dados['cargo']} em ${dados['empresa']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  "Ganho Fixo: R\$ ${dados['ganho'].toStringAsFixed(2)}",
                  style:
                      const TextStyle(color: Colors.greenAccent, fontSize: 20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
