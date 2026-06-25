import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart'; // Mantém o import para ler o AstraTheme
import '../widgets/app_drawer.dart';
import '../widgets/fundo_cosmico.dart';
import '../services/preferences_service.dart';

import 'cadastro_page.dart';
import 'navegacao_page.dart';

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
        MaterialPageRoute(builder: (_) => const NavegacaoPage()), // 🔥 Mudado aqui!
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
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      body: FundoCosmico(
        child: SafeArea(
          child: Center(
            child: _loading
                ? CircularProgressIndicator(color: theme.primaryColor)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone Espacial Centralizado como Fallback/Estilo se não quiser usar asset fixo
                        Icon(
                          Icons.blur_circular,
                          size: 120,
                          color: AstraTheme.primary.withOpacity(0.8),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "FinanceControl",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "MARK I",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w600,
                            color: AstraTheme.secondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Controle financeiro orbital, moderno e inteligente.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 🚀 Botão de Entrada Orbital
                        SizedBox(
                          width: 240,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _entrar,
                            icon: const Icon(Icons.bolt, size: 20),
                            label: Text(
                              _usuarioExiste
                                  ? "ENTRAR NO PAINEL"
                                  : "INICIAR TRIPULAÇÃO",
                              style: const TextStyle(letterSpacing: 1),
                            ),
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