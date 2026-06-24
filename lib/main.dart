import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Onde reside o AstraTheme unificado
import 'pages/splash_screen.dart';

void main() {
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
      theme: AstraTheme.themeData, 
      
      home: const SplashScreen(),
    );
  }
}