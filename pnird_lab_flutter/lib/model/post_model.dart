import 'package:pnirdlab/model/user_model.dart';

class Post {
  final String id;
  final User user;
  String? description;
  String? img;
  List<int>? likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
    this.description,
    this.img,
    List<int>? likes,
    required this.createdAt,
    required this.updatedAt,
  }) : likes = likes ?? []; //Initialize likes with an empty list if null

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      user: User.fromJson(json['userId']),
      description: json['description'] ?? '', // Handle null case
      img: json['img'] ?? '', // Handle null case
      likes: json['likes'] != null
          ? List<int>.from(json['likes'])
          : [], // Handle null case
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
