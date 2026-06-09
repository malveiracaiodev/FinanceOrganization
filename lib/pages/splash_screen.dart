import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../services/controle_service.dart';

import 'dashboard_page.dart';
import 'cadastro_page.dart';
import 'widgets/fundo_cosmico.dart' as fundo;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _startApp();
  }

  Future<void> _startApp() async {
    try {
      final user = await PreferencesService.carregarUsuario();
      await ControleService.carregarControle();

      if (!mounted) return;

      setState(() => _loading = false);

      if (user == null) {
        _goToCadastro();
      } else {
        _goToDashboard();
      }
    } catch (e) {
      debugPrint("Splash error: $e");

      if (!mounted) return;
      _goToCadastro();
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  void _goToCadastro() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fundo.FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  "assets/icone.png",
                  height: 120,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "FinanceControl Mark I",
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _loading
                    ? "Inicializando sistema..."
                    : "Carregando concluído",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}