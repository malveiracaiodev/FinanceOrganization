import 'package:flutter/material.dart';

class AstraTheme {
  // Cores de Identidade Cósmica (União do Neon com o Deep Space)
  static const Color primary = Color(0xFF00D4FF);   // Ciano Elétrico
  static const Color secondary = Color(0xFF00FFC8); // Verde Neon
  static const Color background = Color(0xFF010F1F); // Fundo Espacial Profundo
  static const Color surface = Color(0xFF051424);    // Superfície dos Cards Espaciais

  // Estados financeiros
  static const Color successColor = Color(0xFF00E676);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color dangerColor = Color(0xFFFF5252);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        error: dangerColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          letterSpacing: -0.5,
          fontFamily: 'Space Grotesk',
        ),
      ),

      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.7),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold, 
            letterSpacing: 0.5,
            fontSize: 16,
            fontFamily: 'Space Grotesk',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            fontFamily: 'Space Grotesk',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Space Grotesk',
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
        prefixIconColor: primary,
        suffixIconColor: Colors.white38,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dangerColor, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dangerColor, width: 1.8),
        ),
        errorStyle: const TextStyle(color: dangerColor, fontWeight: FontWeight.w500),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconColor: primary,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
        // CORREÇÃO: Alterada de 'white50' (inválida) para 'white54'
        subtitleTextStyle: const TextStyle(
          fontSize: 13,
          color: Colors.white54,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.05),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface.withValues(alpha: 0.6),
        disabledColor: surface.withValues(alpha: 0.2),
        selectedColor: primary.withValues(alpha: 0.2),
        secondarySelectedColor: secondary.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: secondary, fontSize: 13),
      ),

      // CORREÇÃO: Alterado tipo de 'DialogTheme' para 'DialogThemeData' exigido pelo MaterialApp
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.95),
        indicatorColor: primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: Colors.white38);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary, 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              fontFamily: 'Space Grotesk',
            );
          }
          return const TextStyle(
            color: Colors.white38, 
            fontSize: 12,
            fontFamily: 'Space Grotesk',
          );
        }),
      ),

      fontFamily: 'Space Grotesk',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        // CORREÇÃO: Alterada de 'white50' (inválida) para 'white54'
        bodySmall: TextStyle(fontSize: 12, color: Colors.white54),
      ),
    );
  }
}