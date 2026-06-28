import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../pages/navegacao_page.dart';
import 'cadastro_page.dart';
import '../widgets/fundo_cosmico.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.90,
      end: 1.10,
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
      // 🛰️ Tempo mínimo para estabilização de sistemas
      await Future.delayed(const Duration(seconds: 2));

      // 🔍 Verificação de telemetria: Usuário cadastrado?
      final cadastrado = await PreferencesService.cadastroExiste();

      if (!mounted) return;

      if (cadastrado) {
        // Redirecionamento para o Hub Central
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavegacaoPage()),
        );
      } else {
        // Redirecionamento para o Módulo de Cadastro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CadastroPage()),
        );
      }
    } catch (e) {
      debugPrint("Erro crítico no sistema de inicialização: $e");
      // Fallback de emergência
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CadastroPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color corCianoNeon = Color(0xFF00B4D8);

    return Scaffold(
      body: FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: const Icon(
                  Icons.donut_large_rounded,
                  size: 80,
                  color: corCianoNeon,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "FINANÇAS MARK I",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sistemas prontos para monitorização.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}