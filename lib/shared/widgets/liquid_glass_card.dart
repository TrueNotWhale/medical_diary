import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable Liquid Glass / Glassmorphism card widget.
/// Optimized for 90/120Hz displays: uses lightweight gradient instead of heavy BackdropFilter by default.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? tintColor;
  final double blurSigma;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool useBlur;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.tintColor,
    this.blurSigma = 6, // Optimization: lowered from 18 to 6
    this.borderWidth = 1.2,
    this.useBlur = false, // Optimization: Default to lightweight hardware imitation
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final innerContainer = Container(
      decoration: BoxDecoration(
        color: useBlur 
            ? (tintColor ?? const Color(0x1AFFFFFF)) 
            : Colors.transparent,
        gradient: useBlur ? null : LinearGradient(
          colors: [
            tintColor ?? Colors.white.withOpacity(0.08),
            tintColor?.withOpacity(0.02) ?? Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: borderWidth,
        ),
        boxShadow: useBlur ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    Widget content = innerContainer;
    
    if (useBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: innerContainer,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    
    return content;
  }
}

/// Accent glass card for abnormal markers — glowing ruby or amber tint.
class AccentGlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool useBlur;

  const AccentGlassCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(12),
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final innerContainer = Container(
      decoration: BoxDecoration(
        color: useBlur ? accentColor.withOpacity(0.18) : Colors.transparent,
        gradient: useBlur ? null : LinearGradient(
          colors: [
            accentColor.withOpacity(0.20),
            accentColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (useBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: innerContainer,
        ),
      );
    }

    return innerContainer;
  }
}
