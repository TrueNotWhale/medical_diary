import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Renders decorative glowing orbs in the background to simulate
/// the Apple Liquid Glass light-refraction effect.
class GlowingOrbsBackground extends StatelessWidget {
  final Widget child;

  const GlowingOrbsBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.bgDark,
                AppTheme.bgDeep,
                Color(0xFF070B17),
              ],
            ),
          ),
        ),
        // Aquamarine orb – top left
        Positioned(
          top: -80,
          left: -60,
          child: _Orb(color: AppTheme.aquamarine, size: 280),
        ),
        // Indigo orb – centre right
        Positioned(
          top: 200,
          right: -100,
          child: _Orb(color: AppTheme.indigo, size: 260),
        ),
        // Coral orb – bottom
        Positioned(
          bottom: -80,
          left: 80,
          child: _Orb(color: AppTheme.coral, size: 220),
        ),
        // Content layer
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
