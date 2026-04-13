class Post {
  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isLocked,
    required this.likes,
    required this.createdAt,
    required this.creatorId,
    required this.creatorUsername,
    this.creatorAvatar,
    this.price,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String? image;
  final bool isLocked;
  final int likes;
  final DateTime createdAt;
  final String creatorId;
  final String creatorUsername;
  final String? creatorAvatar;
  final double? price;
  final List<String> tags;

  bool get isAccessible => !isLocked || (image != null && description != null);

  factory Post.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>? ?? {};
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      creatorId: creator['id'] as String? ?? '',
      creatorUsername: creator['username'] as String? ?? '',
      creatorAvatar: creator['avatar'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
