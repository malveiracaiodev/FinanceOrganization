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
    final theme = Theme.of(context);

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
            const Color(0xFF131C32).withValues(alpha: opacity), // Tom de transição inferior
          ],
        ),
      ),
      child: Stack(
        children: [
          // 🛸 Camada 2: Nebulosa Brilhante Dinâmica (Gradiente Radial)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.6), // Concentrado no canto superior direito
                  radius: 1.5,
                  colors: [
                    // CORREÇÃO: Utiliza a cor primária dinâmica do seu tema central.
                    // Se você alterar o tom neon do AstraTheme no futuro, a nebulosa se adaptará na hora!
                    theme.primaryColor.withValues(alpha: opacity * 0.12), // Brilho neon sutil
                    Colors.transparent, // Dissolve suavemente no escuro espacial
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