import 'package:pnirdlab/model/user_model.dart';

class Post {
  final String id;
  final User user;
  String? description;
  String? img;
  List<String>? likes;
  List<dynamic>? comments; // Add comments field
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
    this.description,
    this.img,
    List<String>? likes,
    List<dynamic>? comments,
    required this.createdAt,
    required this.updatedAt,
  }) : likes = likes ?? [], //Initialize likes with an empty list if null
       comments = comments ?? []; //Initialize comments with an empty list if null

  factory Post.fromJson(Map<String, dynamic> json) {
    final userData = json['userId'];
    final user = userData is Map
        ? User.fromJson(Map<String, dynamic>.from(userData))
        : User(
            id: userData?.toString() ?? '',
            firebaseUID: '',
            username: 'Unknown',
            email: '',
            profilePicture: '',
            bio: '',
          );
    final created = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updated = DateTime.tryParse(json['updatedAt']?.toString() ?? '');

    return Post(
      id: json['_id']?.toString() ?? '',
      user: user,
      description: json['description']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      likes: json['likes'] is List
          ? (json['likes'] as List).map((like) => like.toString()).toList()
          : [],
      comments: json['comments'] is List
          ? List<dynamic>.from(json['comments'] as List)
          : [],
      createdAt: (created ?? DateTime.now()).toLocal(),
      updatedAt: (updated ?? created ?? DateTime.now()).toLocal(),
    );
  }
}
