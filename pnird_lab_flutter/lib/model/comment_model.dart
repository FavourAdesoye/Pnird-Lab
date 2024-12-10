class Reply {
  final String username;
  final String comment;
  final DateTime createdAt;

  Reply(
      {required this.username, required this.comment, required this.createdAt});

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      username: json['username'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Comment {
  final String id;
  final String entityId;
  final String entityType;
  final String username;
  final String comment;
  final DateTime createdAt;
  final List<Reply> replies;

  Comment(
      {required this.id,
      required this.entityId,
      required this.entityType,
      required this.username,
      required this.comment,
      required this.createdAt,
      required this.replies});

  // Factory constructor to create a Comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    var replyList = json['replies'] as List;
    List<Reply> replies = replyList.map((i) => Reply.fromJson(i)).toList();

    return Comment(
      id: json['_id'],
      entityId: json['entityId'],
      entityType: json['entityType'],
      username: json['username'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: replies,
    );
  }
}
