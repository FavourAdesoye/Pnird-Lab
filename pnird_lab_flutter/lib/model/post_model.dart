class Post {
  final String id;
  final String userId;
  final String description;
  final String img;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.description,
    required this.img,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      userId: json['userId'],
      description: json['description'] ?? '',
      img: json['img'] ?? '',
      likes: List<String>.from(json['likes']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
