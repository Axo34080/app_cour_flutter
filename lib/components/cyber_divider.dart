import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Divider cyberpunk avec texte central optionnel.
///
/// ```dart
/// const CyberDivider()
/// const CyberDivider(label: 'ou')
/// CyberDivider(color: AppColors.neonPink)
/// ```
class CyberDivider extends StatelessWidget {
  const CyberDivider({
    super.key,
    this.label,
    this.color = AppColors.neonCyan,
  });

  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(
        color: color.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );

    if (label == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: line,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: TextStyle(
                color: color.withValues(alpha: 0.5),
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
