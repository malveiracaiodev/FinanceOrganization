import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// importa suas páginas reais
import 'home_page.dart';
import 'semi_cadastro_page.dart';
import 'fundo_cosmico.dart' as fundo;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navegar();
  }

  Future<void> _navegar() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final cadastroFeito = prefs.getBool('cadastroFeito') ?? false;

    if (!mounted) return; // garante que o widget ainda existe

    if (cadastroFeito) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SemiCadastroPage()),
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
    return Scaffold(
      body: fundo.FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Image.asset("assets/icone.png", height: 120),
              ),
              const SizedBox(height: 20),
              const Text(
                "Finance Organization Mark I",
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
