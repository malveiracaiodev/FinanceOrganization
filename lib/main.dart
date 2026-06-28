import 'package:flutter/material.dart';
import 'pages/navegacao_page.dart'; // 🛸 Importamos a página de navegação correta

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
      // 🎯 CORREÇÃO: O ponto de entrada agora é a NavegacaoPage, restaurando o menu inferior e as funções
      home: const NavegacaoPage(), 
    );
  }
}