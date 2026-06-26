import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Onde reside o AstraTheme unificado
import 'pages/splash_screen.dart';

void main() {
  // Garante que os plugins nativos (como SharedPreferences) funcionem antes do runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinanceControl Mark I',
      
      // 🌌 CONEXÃO: Mudando para o tema espacial que o Stitch gerou
      theme: AstraTheme.themeData.copyWith(
        // Força o fundo padrão por baixo de todos os Scaffolds para a cor do espaço profundo
        scaffoldBackgroundColor: const Color(0xFF060B16),
      ), 
      
      home: const SplashScreen(),
    );
  }
}