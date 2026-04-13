import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CyberCard extends StatelessWidget {
  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.margin = const EdgeInsets.all(24),
    this.glowColor = AppColors.neonCyan,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
