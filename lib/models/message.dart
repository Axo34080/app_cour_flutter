class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    required this.type,
    this.fileName,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String? content;
  final String type; // 'text' | 'file'
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        receiverId: json['receiverId'] as String,
        content: json['content'] as String?,
        type: json['type'] as String? ?? 'text',
        fileName: json['fileName'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type,
        'fileName': fileName,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}
