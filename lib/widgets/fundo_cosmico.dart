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
        // 🌌 Camada 1: O Espaço Profundo (Gradiente Linear)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF040814).withValues(alpha: opacity), // Mais escuro no topo
            const Color(0xFF0B1224).withValues(alpha: opacity),
            const Color(0xFF131C32).withValues(alpha: opacity), // Tom de transição
          ],
        ),
      ),
      child: Stack(
        children: [
          // 🛸 Camada 2: Nebulosa Brilhante Stitch (Gradiente Radial)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.6), // Concentrado no canto superior direito
                  radius: 1.5,
                  colors: [
                    const Color(0xFF00B4D8).withValues(alpha: opacity * 0.12), // Brilho Ciano Neon sutil
                    Colors.transparent, // Dissolve suavemente no escuro
                  ],
                ),
              ),
            ),
          ),
          
          // Camada 3: O conteúdo real da tela (Seus botões, textos, etc.)
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}