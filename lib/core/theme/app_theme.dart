import 'package:flutter/material.dart';

class AstraTheme {
  // Cores de Identidade Cósmica (União do seu Neon com o Deep Space do Stitch)
  static const Color primary = Color(0xFF00D4FF);   // Seu Ciano Elétrico
  static const Color secondary = Color(0xFF00FFC8); // Seu Verde Neon
  static const Color background = Color(0xFF010F1F); // Fundo Espacial Profundo do Stitch
  static const Color surface = Color(0xFF051424);    // Superfície dos Cards Espaciais

  // 🔥 Seus Estados financeiros mantidos intactos
  static const Color successColor = Color(0xFF00E676);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color dangerColor = Color(0xFFFF5252);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        error: dangerColor,
      ),

      // Customização de AppBar profissional e limpa
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      ),

      // Seus Cards adaptados ao estilo Glassmorphism/Space do Stitch
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.6), // Ajustado para conversar com a opacidade do painel
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),

      // Seus botões com a cor Neon em destaque
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // 🛠️ ADICIONADO: Input Decoration global para as telas de lançamento (Imagem 1 do Stitch)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),

      // Tipografia robusta para o Painel de Controle
      fontFamily: 'Space Grotesk', // Se não tiver a fonte adicionada no pubspec, ele usa a nativa automaticamente
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
    );
  }
}