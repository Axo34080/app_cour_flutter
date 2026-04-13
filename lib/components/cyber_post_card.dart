import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../utils/api.dart';
import '../utils/time_format.dart';
import 'cyber_avatar.dart';

class CyberPostCard extends StatelessWidget {
  const CyberPostCard({super.key, required this.post});

  final Post post;

  String _resolveImageUrl(String raw) {
    if (raw.startsWith('http') || raw.startsWith('data:')) return raw;
    return '${Api.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête créateur
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CyberAvatar(
                  username: post.creatorUsername,
                  avatarPath: post.creatorAvatar,
                  radius: 18,
                  showGlow: false,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.creatorUsername,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        TimeFormat.relative(post.createdAt),
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isLocked && !post.isAccessible)
                  Icon(Icons.lock_outline, size: 16,
                      color: AppColors.neonPink.withValues(alpha: 0.7)),
              ],
            ),
          ),

          // Image
          if (post.image != null && post.isAccessible)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                _resolveImageUrl(post.image!),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          else if (post.isLocked && !post.isAccessible)
            _LockedOverlay(height: 220),

          // Contenu texte
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Text(
              post.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          if (post.description != null && post.isAccessible)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
              child: Text(
                post.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

          // Pied : likes + tags
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 16, color: AppColors.neonPink.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.tags.map((t) => '#$t').join(' '),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.neonCyan.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded,
              size: 36, color: AppColors.neonPink.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text(
            'Contenu réservé aux abonnés',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
