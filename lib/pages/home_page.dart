import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';
import '../services/preferences_service.dart';

import 'cadastro_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  bool _usuarioExiste = false;

  @override
  void initState() {
    super.initState();
    _verificarUsuario();
  }

  Future<void> _verificarUsuario() async {
    final existe = await PreferencesService.cadastroExiste();

    if (!mounted) return;

    setState(() {
      _usuarioExiste = existe;
      _loading = false;
    });
  }

  void _entrar() {
    if (_usuarioExiste) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CadastroPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: SafeArea(
          child: Center(
            child: _loading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/meu_logotipo.png",
                          height: 140,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "Finance Organization",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Controle financeiro simples, moderno e eficiente.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _entrar,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              _usuarioExiste
                                  ? "Ir para o Dashboard"
                                  : "Começar Agora",
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        Text(
                          "MARK I",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 3,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}