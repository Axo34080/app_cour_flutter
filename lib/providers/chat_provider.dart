import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../services/socket_service.dart';

class IncomingCall {
  const IncomingCall({
    required this.fromUserId,
    required this.callerUsername,
    required this.roomUrl,
  });
  final String fromUserId;
  final String callerUsername;
  final String roomUrl;
}

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required MessageService messageService,
    required SocketService socketService,
  })  : _messages = messageService,
        _socket = socketService;

  final MessageService _messages;
  final SocketService _socket;

  String? _token;
  List<Conversation> _conversations = [];
  final Map<String, List<Message>> _history = {};
  bool _conversationsLoading = false;
  String? _error;
  IncomingCall? _incomingCall;

  // Stream pour signaler à ChatPage de scroller vers le bas
  final _scrollSignal = StreamController<String>.broadcast();
  Stream<String> get onScrollNeeded => _scrollSignal.stream;

  StreamSubscription<Message>? _newMessageSub;
  StreamSubscription<Message>? _messageSentSub;
  StreamSubscription<IncomingCall>? _incomingCallSub;

  List<Conversation> get conversations => _conversations;
  bool get conversationsLoading => _conversationsLoading;
  String? get error => _error;
  IncomingCall? get incomingCall => _incomingCall;

  int get totalUnread => _conversations
      .where((c) => c.isUnread(_myId ?? ''))
      .length;

  String? _myId;
  void setMyId(String id) => _myId = id;

  List<Message> historyFor(String userId) => _history[userId] ?? [];

  void connect(String token) {
    if (_token == token) return;
    _token = token;
    _socket.connect(token);
    _listenSocket();
  }

  void disconnect() {
    _newMessageSub?.cancel();
    _messageSentSub?.cancel();
    _incomingCallSub?.cancel();
    _socket.disconnect();
    _token = null;
    _myId = null;
    _conversations = [];
    _history.clear();
    _incomingCall = null;
    notifyListeners();
  }

  void _listenSocket() {
    _newMessageSub?.cancel();
    _messageSentSub?.cancel();
    _incomingCallSub?.cancel();

    _newMessageSub = _socket.onNewMessage.listen((msg) {
      _insertMessage(msg);
      _updateConversationFromMessage(msg);
      _scrollSignal.add(msg.senderId);
      notifyListeners();
    });

    _messageSentSub = _socket.onMessageSent.listen((msg) {
      _insertMessage(msg);
      _updateConversationFromMessage(msg);
      _scrollSignal.add(msg.receiverId);
      notifyListeners();
    });

    _incomingCallSub = _socket.onIncomingCall.listen((call) {
      _incomingCall = call;
      notifyListeners();
    });
  }

  void _insertMessage(Message msg) {
    final partnerId = msg.senderId == _myId ? msg.receiverId : msg.senderId;
    final list = List<Message>.from(_history[partnerId] ?? []);
    if (!list.any((m) => m.id == msg.id)) list.add(msg);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _history[partnerId] = list;
  }

  void _updateConversationFromMessage(Message msg) {
    final partnerId = msg.senderId == _myId ? msg.receiverId : msg.senderId;
    final idx = _conversations.indexWhere((c) => c.userId == partnerId);
    if (idx >= 0) {
      final updated = List<Conversation>.from(_conversations);
      final c = updated[idx];
      updated[idx] = Conversation(
        userId: c.userId,
        username: c.username,
        avatar: c.avatar,
        lastMessage: msg,
      );
      _conversations = updated;
    } else {
      // Nouvelle conversation apparue via socket — recharger la liste
      loadConversations();
    }
  }

  Future<void> loadConversations() async {
    if (_token == null) return;
    _conversationsLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _messages.getConversations(_token!);
    } catch (_) {
      _error = 'Impossible de charger les conversations';
    } finally {
      _conversationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String userId) async {
    if (_token == null) return;
    try {
      _history[userId] = await _messages.getHistory(_token!, userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String userId) async {
    if (_token == null) return;
    await _messages.markAsRead(_token!, userId);
    final idx = _conversations.indexWhere((c) => c.userId == userId);
    if (idx >= 0) {
      final c = _conversations[idx];
      final updatedMsg = Message(
        id: c.lastMessage.id,
        senderId: c.lastMessage.senderId,
        receiverId: c.lastMessage.receiverId,
        content: c.lastMessage.content,
        type: c.lastMessage.type,
        fileName: c.lastMessage.fileName,
        isRead: true,
        createdAt: c.lastMessage.createdAt,
      );
      final updated = List<Conversation>.from(_conversations);
      updated[idx] = Conversation(
        userId: c.userId,
        username: c.username,
        avatar: c.avatar,
        lastMessage: updatedMsg,
      );
      _conversations = updated;
      notifyListeners();
    }
  }

  void sendMessage({required String receiverId, required String content, String type = 'text', String? fileName}) {
    _socket.sendMessage(receiverId: receiverId, content: content, type: type, fileName: fileName);
  }

  void sendCallRequest({required String targetUserId, required String roomUrl}) {
    _socket.requestCall(targetUserId: targetUserId, roomUrl: roomUrl);
  }

  void acceptCall(String targetUserId) {
    _socket.acceptCall(targetUserId);
    _incomingCall = null;
    notifyListeners();
  }

  void rejectCall(String targetUserId) {
    _socket.rejectCall(targetUserId);
    _incomingCall = null;
    notifyListeners();
  }

  void clearIncomingCall() {
    _incomingCall = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _newMessageSub?.cancel();
    _messageSentSub?.cancel();
    _incomingCallSub?.cancel();
    _scrollSignal.close();
    _socket.dispose();
    super.dispose();
  }
}
