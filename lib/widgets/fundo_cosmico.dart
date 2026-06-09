import 'package:flutter/material.dart';

class FundoCosmico extends StatelessWidget {
  final Widget child;
  final double opacity;

  const FundoCosmico({
    super.key,
    required this.child,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0F1E).withAlpha((opacity * 255).round()),
            const Color(0xFF121A2A).withAlpha((opacity * 255).round()),
            const Color(0xFF1A2740).withAlpha((opacity * 255).round()),
          ],
        ),
      ),
      child: child,
    );
  }
}