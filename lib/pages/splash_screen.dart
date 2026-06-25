import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/preferences_service.dart';
import '../services/controle_service.dart';
import '../services/parcelas_service.dart'; 

import 'dashboard_page.dart';
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

  bool _loading = true;

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
      // 1. Carrega os dados básicos de usuário e finanças
      final user = await PreferencesService.carregarUsuario();
      await ControleService.carregarControle();

      // 2. LÓGICA DE TRANSIÇÃO DE CICLO MENSAL
      if (user != null) {
        // TODO: Implementar a verificação real se o mês mudou no PreferencesService
        final bool mesMudou = false; 
        
        if (mesMudou) {
          // Se o mês mudou, roda o processamento controlado das parcelas
          await ParcelasService.processarMes();
          // Recarrega o controle para garantir que a UI pegue os novos valores consolidados
          await ControleService.carregarControle();
        }
      }

      if (!mounted) return;

      setState(() => _loading = false);

      // Pequena pausa com os sistemas prontos para suavizar a transição
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // 3. Roteamento baseado na existência do perfil de usuário
      if (user == null) {
        _goToCadastro();
      } else {
        _goToDashboard();
      }
    } catch (e) {
      debugPrint("Erro na inicialização do app: $e");

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
      body: FundoCosmico( 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Icon(
                  Icons.donut_large_rounded, // Ícone moderno e limpo, alinhado ao nicho finanças/gráficos
                  size: 80,
                  color: AstraTheme.primary,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "ASTRACONTROL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _loading ? "Carregando dados financeiros..." : "Sistemas prontos.",
                style: const TextStyle(
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