import 'message.dart';

class Conversation {
  const Conversation({
    required this.userId,
    required this.username,
    this.avatar,
    required this.lastMessage,
  });

  final String userId;
  final String username;
  final String? avatar;
  final Message lastMessage;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        userId: json['userId'] as String,
        username: json['username'] as String,
        avatar: json['avatar'] as String?,
        lastMessage: Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      );

  bool isUnread(String myUserId) =>
      lastMessage.receiverId == myUserId && !lastMessage.isRead;
}
