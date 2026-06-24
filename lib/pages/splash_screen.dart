import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../services/controle_service.dart';
import '../services/parcelas_service.dart'; // Importado para lidar com as parcelas na virada

import 'dashboard_page.dart';
import 'cadastro_page.dart';
import '../widgets/fundo_cosmico.dart'; // Ajustado o caminho do import

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
      // 1. Carrega os dados básicos de usuário e finanças
      final user = await PreferencesService.carregarUsuario();
      await ControleService.carregarControle();

      // 2. 🔥 LÓGICA DO DIA 1º (Verificação de ciclo mensal)
      if (user != null) {
        // Verifica se o mês mudou desde a última execução salva
        final bool mesMudou = false; 
        
        if (mesMudou) {
          // Se o mês mudou, roda o processamento controlado das parcelas
          await ParcelasService.processarMes();
          // Recarrega o controle para garantir que a UI pegue os valores novos abastados
          await ControleService.carregarControle();
        }
      }

      if (!mounted) return;

      setState(() => _loading = false);

      // 3. Roteamento orbital baseado na existência do usuário
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
      body: FundoCosmico( // Removido o alias 'fundo.' para ficar limpo
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Icon(
                  Icons.rocket_launch, // Usando Icon temporário caso o asset dê alguma falha de path
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "FinanceControl Mark I",
                style: TextStyle(
                  color: Color(0xFF00D4FF), // Seu ciano elétrico do tema
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _loading ? "Inicializando sistemas de órbita..." : "Sistemas prontos.",
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