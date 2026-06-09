import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
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
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}