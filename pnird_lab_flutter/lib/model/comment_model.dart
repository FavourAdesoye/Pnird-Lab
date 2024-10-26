class Comment {
  final String id;
  final String postId;
  final String username;
  final String comment;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.username,
    required this.comment,
    required this.createdAt,
  });

  // Factory constructor to create a Comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      postId: json['postId'],
      username: json['username'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
