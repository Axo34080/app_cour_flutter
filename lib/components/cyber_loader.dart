import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Indicateur de chargement cyberpunk — plein écran ou inline.
///
/// ```dart
/// const CyberLoader()                         // inline, cyan
/// const CyberLoader.fullscreen()              // overlay plein écran
/// CyberLoader(color: AppColors.neonPink)      // rose
/// ```
class CyberLoader extends StatelessWidget {
  const CyberLoader({
    super.key,
    this.color = AppColors.neonCyan,
    this.size = 28,
  }) : _fullscreen = false;

  const CyberLoader.fullscreen({
    super.key,
    this.color = AppColors.neonCyan,
    this.size = 36,
  }) : _fullscreen = true;

  final Color color;
  final double size;
  final bool _fullscreen;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color,
      ),
    );

    if (!_fullscreen) return indicator;

    return Container(
      color: AppColors.background.withValues(alpha: 0.85),
      child: Center(child: indicator),
    );
  }
}
