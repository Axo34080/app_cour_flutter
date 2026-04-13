import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/components.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'conversations.dart';
import 'feed.dart';
import 'profile.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  int _index = 0;

  static const _pages = [
    ConversationsPage(),
    FeedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final unread = chat.totalUnread;

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(index: _index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.neonCyan.withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.chat_bubble_rounded),
                ),
                label: 'Messages',
              ),
              const NavigationDestination(
                icon: Icon(Icons.dynamic_feed_outlined),
                selectedIcon: Icon(Icons.dynamic_feed_rounded),
                label: 'Fil',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
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
