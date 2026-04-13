import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/api.dart';

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

  bool get _isBase64 => avatarPath?.startsWith('data:') ?? false;

  String get _networkUrl {
    if (avatarPath!.startsWith('http')) return avatarPath!;
    return '${Api.baseUrl}$avatarPath';
  }

  Uint8List? get _base64Bytes {
    try {
      final comma = avatarPath!.indexOf(',');
      if (comma == -1) return null;
      return base64Decode(avatarPath!.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: glowColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: showGlow
            ? [BoxShadow(color: glowColor.withValues(alpha: 0.25), blurRadius: 12)]
            : null,
      ),
      child: ClipOval(
        child: _hasAvatar ? _buildImage(size) : _InitialsCircle(initials: _initials, size: size, color: glowColor),
      ),
    );
  }

  Widget _buildImage(double size) {
    if (_isBase64) {
      final bytes = _base64Bytes;
      if (bytes == null) {
        return _InitialsCircle(initials: _initials, size: size, color: glowColor);
      }
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _InitialsCircle(initials: _initials, size: size, color: glowColor),
      );
    }

    return Image.network(
      _networkUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _InitialsCircle(initials: _initials, size: size, color: glowColor),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({
    required this.initials,
    required this.size,
    required this.color,
  });

  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surface,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
