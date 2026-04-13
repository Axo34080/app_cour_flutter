import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/components.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _postService = PostService();
  final _userService = UserService();

  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = context.read<AuthProvider>().token!;
      final creatorIds = await _userService.getRawSubscriptions(token);
      final posts = await _postService.getFeed(token, creatorIds);
      if (!mounted) return;
      setState(() => _posts = posts);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fil d\'actualité')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CyberLoader());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.neonPink.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            CyberButton.secondary(
                label: 'Réessayer',
                icon: Icons.refresh,
                onPressed: _load,
                expand: false),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dynamic_feed_outlined,
                size: 56, color: AppColors.neonCyan.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Aucun post pour le moment',
                style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text('Abonnez-vous à des créateurs sur le site web',
                style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                    fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (_, i) => CyberPostCard(post: _posts[i]),
      ),
    );
  }
}
