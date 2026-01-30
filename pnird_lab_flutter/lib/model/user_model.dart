class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String firebaseUID;
  String profilePicture;
  bool? isAdmin;
  String? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.firebaseUID,
    this.profilePicture = '',
    this.isAdmin,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'] ?? '',
      bio: json['bio'] ?? '',
      firebaseUID: json['firebaseUID'] ?? '',
      isAdmin: json['isAdmin'] == null
          ? null
          : json['isAdmin'] as bool, // Ensure proper boolean parsing
      role: json['role'] as String?,
    );
  }
}
