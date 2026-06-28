import 'package:flutter/material.dart';
import 'pages/navegacao_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/splash_screen.dart'; // Importando a Splash para fazer a checagem

void main() async {
  // 🚨 CRÍTICO: Garante que o armazenamento local e as funções nativas respondam no APK de Release
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
      theme: ThemeData(
        brightness: Brightness.dark, // Garante que o tema escuro padrão do seu design seja herdado corretamente
        scaffoldBackgroundColor: const Color(0xFF060B16),
      ),
      
      // 🎯 MODIFICAÇÃO MARK I: Definimos a SplashScreen como o ponto de entrada oficial do app
      initialRoute: '/',
      
      // 🛸 MAPA DE ROTAS: Centraliza os caminhos para evitar erros de navegação no AppDrawer e nas Páginas
      routes: {
        '/': (context) => const SplashScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/main_hub': (context) => const NavegacaoPage(), // O Hub com o menu inferior e a dashboard
      },
    );
  }
}