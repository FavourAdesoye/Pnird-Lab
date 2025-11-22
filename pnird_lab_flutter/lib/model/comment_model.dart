class Reply {
  final String username;
  final String comment;
  final String? profilePicture; // Add profile picture field
  final DateTime createdAt;

  Reply(
      {required this.username, 
       required this.comment, 
       this.profilePicture,
       required this.createdAt});

  factory Reply.fromJson(Map<String, dynamic> json) {
    // Handle both populated userId object and direct profilePicture field
    String? profilePicture;
    
    if (json['userId'] != null) {
      if (json['userId'] is Map) {
        profilePicture = json['userId']['profilePicture'];
      } else if (json['userId'] is String) {
        // If userId is a string (ObjectId), we'll fetch the profile picture later
        // For now, set it to null and it will be populated by the comment card
        profilePicture = null;
      }
    } else if (json['profilePicture'] != null) {
      profilePicture = json['profilePicture'];
    }

    return Reply(
      username: json['username'],
      comment: json['comment'],
      profilePicture: profilePicture,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }
}

class Comment {
  final String id;
  final String entityId;
  final String entityType;
  final String username;
  final String comment;
  final String? profilePicture; // Add profile picture field
  final DateTime createdAt;
  final List<Reply> replies;

  Comment(
      {required this.id,
      required this.entityId,
      required this.entityType,
      required this.username,
      required this.comment,
      this.profilePicture,
      required this.createdAt,
      required this.replies});

  // Factory constructor to create a Comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    var replyList = json['replies'] as List;
    List<Reply> replies = replyList.map((i) => Reply.fromJson(i)).toList();


    // Handle both populated userId object and direct profilePicture field
    String? profilePicture;
    if (json['userId'] != null) {
      if (json['userId'] is Map) {
        profilePicture = json['userId']['profilePicture'];
      } else if (json['userId'] is String) {
        // If userId is a string (ObjectId), we can't get profile picture from it
        profilePicture = null;
      }
    }

    return Comment(
      id: json['_id'],
      entityId: json['entityId'],
      entityType: json['entityType'],
      username: json['username'],
      comment: json['comment'],
      profilePicture: profilePicture,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      replies: replies,
    );
  }
}
