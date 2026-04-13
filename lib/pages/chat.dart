import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/components.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/call_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.userId,
    required this.username,
    this.avatar,
  });

  final String userId;
  final String username;
  final String? avatar;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollCtrl = ScrollController();
  final _callService = CallService();
  final _userService = UserService();
  bool _historyLoading = true;
  bool _callLoading = false;
  StreamSubscription<String>? _scrollSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chat = context.read<ChatProvider>();
      await chat.loadHistory(widget.userId);
      await chat.markAsRead(widget.userId);
      if (mounted) setState(() => _historyLoading = false);
      _scrollToBottom();

      // Scroll automatique sur nouveau message de cette conversation
      _scrollSub = chat.onScrollNeeded.listen((partnerId) {
        if (partnerId == widget.userId) _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _scrollSub?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend(String content) {
    context.read<ChatProvider>().sendMessage(
          receiverId: widget.userId,
          content: content,
        );
  }

  Future<void> _onAttach() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    try {
      final bytes = await picked.readAsBytes();
      final url = await _userService.uploadAvatar(auth.token!, bytes, picked.name);
      if (!mounted) return;
      chat.sendMessage(
        receiverId: widget.userId,
        content: url,
        type: 'file',
        fileName: picked.name,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du fichier')),
      );
    }
  }

  Future<void> _startCall() async {
    setState(() => _callLoading = true);
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    try {
      final roomUrl = await _callService.createRoom(auth.token!);
      if (!mounted) return;
      chat.sendCallRequest(targetUserId: widget.userId, roomUrl: roomUrl);
      await launchUrl(Uri.parse(roomUrl), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de démarrer l\'appel')),
      );
    } finally {
      if (mounted) setState(() => _callLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = context.read<AuthProvider>().user?.id ?? '';
    final messages = context.select<ChatProvider, List>(
      (c) => c.historyFor(widget.userId),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CyberAvatar(
              username: widget.username,
              avatarPath: widget.avatar,
              radius: 18,
              showGlow: false,
            ),
            const SizedBox(width: 10),
            Text(widget.username),
          ],
        ),
        actions: [
          if (_callLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CyberLoader(size: 20),
            )
          else
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              color: AppColors.neonCyan,
              onPressed: _startCall,
              tooltip: 'Appel vidéo',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _historyLoading
                ? const Center(child: CyberLoader())
                : messages.isEmpty
                    ? const _EmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => CyberMessageBubble(
                          message: messages[i],
                          isMine: messages[i].senderId == myUserId,
                        ),
                      ),
          ),
          CyberMessageInput(onSend: _onSend, onAttach: _onAttach),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waving_hand_outlined, size: 48,
              color: AppColors.neonCyan.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'Commencez la conversation',
            style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.4), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
