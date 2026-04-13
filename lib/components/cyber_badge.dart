import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge de compteur (ex : messages non lus) positionné en superposition.
///
/// ```dart
/// CyberBadge(count: unreadCount, child: CyberAvatar(...))
/// CyberBadge.dot(child: Icon(Icons.notifications))
/// ```
class CyberBadge extends StatelessWidget {
  const CyberBadge({
    super.key,
    required this.child,
    required this.count,
    this.color = AppColors.neonPink,
    this.maxCount = 99,
  }) : _dotOnly = false;

  const CyberBadge.dot({
    super.key,
    required this.child,
    this.color = AppColors.neonPink,
  })  : count = 1,
        maxCount = 99,
        _dotOnly = true;

  final Widget child;
  final int count;
  final Color color;
  final int maxCount;
  final bool _dotOnly;

  bool get _visible => count > 0;

  String get _label =>
      _dotOnly ? '' : (count > maxCount ? '$maxCount+' : '$count');

  @override
  Widget build(BuildContext context) {
    if (!_visible) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            constraints: BoxConstraints(
              minWidth: _dotOnly ? 10 : 18,
              minHeight: _dotOnly ? 10 : 18,
            ),
            padding: _dotOnly
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: _dotOnly
                ? null
                : Center(
                    child: Text(
                      _label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
