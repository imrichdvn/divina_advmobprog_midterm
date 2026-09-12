class Comment {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String body;
  final int likes;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.body,
    this.likes = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return Comment(
      id: (json['id'] as num).toInt(),
      postId: (json['postId'] as num).toInt(),
      userId: (user['id'] as num).toInt(),
      userName:
          user['fullName'] as String? ?? user['username'] as String? ?? 'User',
      body: json['body'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'body': body,
    'likes': likes,
    'user': {'id': userId, 'fullName': userName},
  };
}
