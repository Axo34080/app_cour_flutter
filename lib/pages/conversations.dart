import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/components.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat.dart';
import 'profile.dart';
import 'search_users.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final myUserId = auth.user?.id ?? '';
    final unread = chat.totalUnread;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: unread > 0
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Messages'),
                    const SizedBox(width: 8),
                    CyberBadge(count: unread, child: const SizedBox(width: 8, height: 8)),
                  ])
                : const Text('Messages'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                tooltip: 'Profil',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchUsersPage()),
            ),
            backgroundColor: AppColors.neonCyan,
            foregroundColor: AppColors.background,
            child: const Icon(Icons.edit_outlined),
          ),
          body: _Body(chat: chat, myUserId: myUserId),
        ),

        // Bannière appel entrant
        if (chat.incomingCall != null)
          CyberIncomingCall(
            callerUsername: chat.incomingCall!.callerUsername,
            onReject: () => chat.rejectCall(chat.incomingCall!.fromUserId),
            onAccept: () async {
              final call = chat.incomingCall!;
              chat.acceptCall(call.fromUserId);
              await launchUrl(
                Uri.parse(call.roomUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.chat, required this.myUserId});
  final ChatProvider chat;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    if (chat.conversationsLoading) return const Center(child: CyberLoader());

    if (chat.error != null) {
      return _ErrorState(
        message: chat.error!,
        onRetry: () => context.read<ChatProvider>().loadConversations(),
      );
    }

    if (chat.conversations.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.surface,
      onRefresh: () => context.read<ChatProvider>().loadConversations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: chat.conversations.length,
        separatorBuilder: (_, _) => const Divider(color: Colors.transparent, height: 4),
        itemBuilder: (context, i) {
          final conv = chat.conversations[i];
          return CyberConversationTile(
            conversation: conv,
            myUserId: myUserId,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  userId: conv.userId,
                  username: conv.username,
                  avatar: conv.avatar,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 56,
              color: AppColors.neonCyan.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Aucune conversation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  )),
          const SizedBox(height: 8),
          Text('Appuyez sur ✏️ pour démarrer une conversation',
              style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.35), fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48,
                color: AppColors.neonPink.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            CyberButton.secondary(
                label: 'Réessayer', icon: Icons.refresh, onPressed: onRetry, expand: false),
          ],
        ),
      ),
    );
  }
}
