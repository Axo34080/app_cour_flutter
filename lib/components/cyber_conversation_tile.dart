import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import 'cyber_avatar.dart';

class CyberConversationTile extends StatelessWidget {
  const CyberConversationTile({
    super.key,
    required this.conversation,
    required this.myUserId,
    required this.onTap,
  });

  final Conversation conversation;
  final String myUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = conversation.isUnread(myUserId);
    final preview = _buildPreview();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unread
                ? AppColors.neonCyan.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _UnreadIndicator(
              show: unread,
              child: CyberAvatar(
                username: conversation.username,
                avatarPath: conversation.avatar,
                radius: 26,
                showGlow: unread,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.username,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        TimeFormat.message(conversation.lastMessage.createdAt),
                        style: TextStyle(
                          color: unread
                              ? AppColors.neonCyan
                              : AppColors.textPrimary.withValues(alpha: 0.4),
                          fontSize: 12,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: TextStyle(
                      color: unread
                          ? AppColors.textPrimary.withValues(alpha: 0.8)
                          : AppColors.textPrimary.withValues(alpha: 0.45),
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildPreview() {
    final msg = conversation.lastMessage;
    final isMine = msg.senderId == myUserId;
    final prefix = isMine ? 'Vous : ' : '';
    if (msg.type == 'file') return '${prefix}Fichier';
    return '$prefix${msg.content ?? ''}';
  }
}

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator({required this.show, required this.child});
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.neonCyan,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
