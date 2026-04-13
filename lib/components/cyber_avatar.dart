import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/api.dart';

/// Avatar circulaire cyberpunk avec glow neon.
///
/// ```dart
/// CyberAvatar(avatarPath: user.avatar, username: user.username)
/// CyberAvatar(avatarPath: null, username: 'Alice', radius: 28)
/// ```
class CyberAvatar extends StatelessWidget {
  const CyberAvatar({
    super.key,
    required this.username,
    this.avatarPath,
    this.radius = 22,
    this.glowColor = AppColors.neonCyan,
    this.showGlow = true,
  });

  final String username;

  /// Chemin relatif retourné par l'API (ex: "/uploads/abc.jpg").
  /// Si null ou vide, affiche les initiales.
  final String? avatarPath;
  final double radius;
  final Color glowColor;
  final bool showGlow;

  String get _initials {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  bool get _hasAvatar => avatarPath != null && avatarPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2 + 4,
      height: radius * 2 + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: glowColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        backgroundImage: _hasAvatar
            ? NetworkImage('${Api.baseUrl}$avatarPath')
            : null,
        onBackgroundImageError: _hasAvatar
            ? (_, _) {} // fallback silencieux → initiales
            : null,
        child: _hasAvatar
            ? null
            : Text(
                _initials,
                style: TextStyle(
                  color: glowColor,
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
