import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart'; // Importação do tema customizado Astra
import 'pages/navegacao_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/splash_screen.dart'; 
import 'pages/configuracoes_page.dart'; // Importação da tela de configurações

void main() async {
  // 🚨 CRÍTICO: Garante que as rotinas nativas e o SharedPreferences respondam corretamente
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Organization',
      debugShowCheckedModeBanner: false,
      
      // ✅ CORREÇÃO: Aplica a identidade cósmica Astra unificada que projetamos
      theme: AstraTheme.themeData, 
      
      // 🎯 MODIFICAÇÃO MARK I: SplashScreen definida como a porta de entrada oficial do sistema
      initialRoute: '/',
      
      // 🛸 MAPA DE ROTAS: Centraliza todas as rotas do Finanças Mark I
      routes: {
        '/': (context) => const SplashScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/main_hub': (context) => const NavegacaoPage(), // Dashboard com menu inferior flutuante
        '/configuracoes': (context) => const ConfiguracoesPage(), // Nova tela de ajustes do comandante
      },
    );
  }
}