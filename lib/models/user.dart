class User {
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    this.bio,
    this.creatorId,
    this.allowVideoCall = false,
  });

  final String id;
  final String email;
  final String username;
  final String? avatar;
  final String? bio;
  final String? creatorId;
  final bool allowVideoCall;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        username: json['username'] as String,
        avatar: json['avatar'] as String?,
        bio: json['bio'] as String?,
        creatorId: json['creatorId'] as String?,
        allowVideoCall: json['allowVideoCall'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'avatar': avatar,
        'bio': bio,
        'creatorId': creatorId,
        'allowVideoCall': allowVideoCall,
      };
}
