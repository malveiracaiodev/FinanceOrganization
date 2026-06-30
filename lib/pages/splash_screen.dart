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
      // 🛰️ Otimização: Executa o delay visual e a checagem de banco em paralelo
      final resultados = await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Tempo de estabilização visual
        PreferencesService.cadastroExiste(),       // Verificação se usuário existe
      ]);

      final bool cadastrado = resultados[1] as bool;

      if (!mounted) return;

      // Redireciona com transição suave
      _navegarPara(cadastrado ? const NavegacaoPage() : const CadastroPage());
    } catch (e) {
      debugPrint("Erro crítico no sistema de inicialização: $e");
      
      if (!mounted) return;
      
      // Fallback de emergência seguro (verificando se ainda está montado)
      _navegarPara(const CadastroPage());
    }
  }

  // Método auxiliar para realizar uma transição fluida do tipo Fade (Esmaecimento)
  void _navegarPara(Widget proximaTela) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => proximaTela,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600), // Suavidade na transição
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
    // Busca a cor diretamente do tema dinâmico configurado no app_theme.dart
    final theme = Theme.of(context);

    return Scaffold(
      body: FundoCosmico(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Icon(
                  Icons.donut_large_rounded,
                  size: 80,
                  color: theme.primaryColor, // Utiliza o Ciano Elétrico unificado do tema
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "FINANÇAS MARK I",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Sistemas prontos para monitorização.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
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