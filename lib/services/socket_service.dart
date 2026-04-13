import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message.dart';
import '../providers/chat_provider.dart' show IncomingCall;
import '../utils/api.dart';

class SocketService {
  io.Socket? _socket;

  final _newMessage = StreamController<Message>.broadcast();
  final _messageSent = StreamController<Message>.broadcast();
  final _incomingCall = StreamController<IncomingCall>.broadcast();

  Stream<Message> get onNewMessage => _newMessage.stream;
  Stream<Message> get onMessageSent => _messageSent.stream;
  Stream<IncomingCall> get onIncomingCall => _incomingCall.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (isConnected) return;

    _socket = io.io(
      '${Api.baseUrl}/chat',
      io.OptionBuilder()
          .setTransports(['polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..on('connected', (_) {})
      ..on('new_message', (data) {
        if (data is Map) {
          _newMessage.add(Message.fromJson(Map<String, dynamic>.from(data)));
        }
      })
      ..on('message_sent', (data) {
        if (data is Map) {
          _messageSent.add(Message.fromJson(Map<String, dynamic>.from(data)));
        }
      })
      ..on('incoming_call', (data) {
        if (data is Map) {
          _incomingCall.add(IncomingCall(
            fromUserId: data['fromUserId'] as String,
            callerUsername: data['callerUsername'] as String,
            roomUrl: data['roomUrl'] as String,
          ));
        }
      })
      ..connect();
  }

  void sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
    String? fileName,
  }) {
    final payload = <String, dynamic>{
      'receiverId': receiverId,
      'content': content,
      'type': type,
    };
    if (fileName != null) payload['fileName'] = fileName;
    _socket?.emit('send_message', payload);
  }

  void requestCall({required String targetUserId, required String roomUrl}) {
    _socket?.emit('call_request', {
      'targetUserId': targetUserId,
      'roomUrl': roomUrl,
    });
  }

  void acceptCall(String targetUserId) {
    _socket?.emit('call_accepted', {'targetUserId': targetUserId});
  }

  void rejectCall(String targetUserId) {
    _socket?.emit('call_rejected', {'targetUserId': targetUserId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _newMessage.close();
    _messageSent.close();
    _incomingCall.close();
  }
}
