import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'chat.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _ctrl = TextEditingController();
  final _userService = UserService();

  List<User> _subscriptions = [];
  List<User> _searchResults = [];
  bool _subsLoading = true;
  bool _searchLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    final token = context.read<AuthProvider>().token!;
    try {
      final subs = await _userService.getSubscriptions(token);
      if (!mounted) return;
      setState(() => _subscriptions = subs);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _subsLoading = false);
    }
  }

  Future<void> _onSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _searchResults = [];
        _lastQuery = '';
      });
      return;
    }
    if (trimmed == _lastQuery) return;
    _lastQuery = trimmed;
    setState(() => _searchLoading = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final results = await _userService.search(token, trimmed);
      if (!mounted || _lastQuery != trimmed) return;
      setState(() => _searchResults = results);
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  bool get _isSearching => _ctrl.text.trim().length >= 2;

  void _openChat(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          userId: user.id,
          username: user.username,
          avatar: user.avatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle conversation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CyberTextField(
              label: 'Rechercher un utilisateur',
              controller: _ctrl,
              prefixIcon: Icons.search,
              autofocus: false,
              onChanged: _onSearch,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isSearching
                ? _SearchBody(
                    results: _searchResults,
                    loading: _searchLoading,
                    onTap: _openChat,
                  )
                : _SubscriptionsBody(
                    subscriptions: _subscriptions,
                    loading: _subsLoading,
                    onTap: _openChat,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Subscriptions list ──────────────────────────────────────────────────────

class _SubscriptionsBody extends StatelessWidget {
  const _SubscriptionsBody({
    required this.subscriptions,
    required this.loading,
    required this.onTap,
  });
  final List<User> subscriptions;
  final bool loading;
  final ValueChanged<User> onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CyberLoader());

    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 48, color: AppColors.neonCyan.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'Vous ne suivez personne',
              style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 4),
            Text(
              'Recherchez un utilisateur ci-dessus',
              style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.3),
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) =>
          const Divider(color: Colors.transparent, height: 4),
      itemBuilder: (context, i) => _UserTile(
        user: subscriptions[i],
        onTap: () => onTap(subscriptions[i]),
      ),
    );
  }
}

// ── Search results ──────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.results,
    required this.loading,
    required this.onTap,
  });
  final List<User> results;
  final bool loading;
  final ValueChanged<User> onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CyberLoader());

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur trouvé',
          style:
              TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.4)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          const Divider(color: Colors.transparent, height: 4),
      itemBuilder: (context, i) => _UserTile(
        user: results[i],
        onTap: () => onTap(results[i]),
      ),
    );
  }
}

// ── Shared tile ─────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});
  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CyberAvatar(
                username: user.username, avatarPath: user.avatar, radius: 24),
            const SizedBox(width: 14),
            Text(
              user.username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
