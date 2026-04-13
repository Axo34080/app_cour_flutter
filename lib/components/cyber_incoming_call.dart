import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bannière d'appel entrant affichée en overlay.
class CyberIncomingCall extends StatelessWidget {
  const CyberIncomingCall({
    super.key,
    required this.callerUsername,
    required this.onAccept,
    required this.onReject,
  });

  final String callerUsername;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam, color: AppColors.neonCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callerUsername,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Appel vidéo entrant…',
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _CallButton(
                icon: Icons.call_end,
                color: AppColors.neonPink,
                onTap: onReject,
              ),
              const SizedBox(width: 8),
              _CallButton(
                icon: Icons.videocam,
                color: AppColors.neonCyan,
                onTap: onAccept,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
