import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CyberButtonVariant { primary, secondary, ghost }

/// Bouton cyberpunk réutilisable — 3 variantes.
///
/// ```dart
/// CyberButton(label: 'Connexion', onPressed: _login)
/// CyberButton.secondary(label: 'Annuler', onPressed: _cancel)
/// CyberButton.ghost(label: 'En savoir plus', onPressed: _info)
/// ```
class CyberButton extends StatelessWidget {
  const CyberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CyberButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  const CyberButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  }) : variant = CyberButtonVariant.secondary;

  const CyberButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = CyberButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final CyberButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// Si true, le bouton prend toute la largeur disponible.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;

    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.background,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final btn = switch (variant) {
      CyberButtonVariant.primary => FilledButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      CyberButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neonPink,
            minimumSize: expand ? const Size.fromHeight(52) : null,
            side: const BorderSide(color: AppColors.neonPink, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: child,
        ),
      CyberButtonVariant.ghost => TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.neonCyan,
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: child,
        ),
    };

    if (!expand || variant == CyberButtonVariant.ghost) return btn;

    return SizedBox(width: double.infinity, child: btn);
  }
}
