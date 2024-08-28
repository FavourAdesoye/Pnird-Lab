class User {
  final String id;
  final String username;
  final String email;
  String? profilePicture;
  bool? isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      profilePicture: json['profilePicture'] ?? '',
      isAdmin: json['isAdmin'] == null
          ? null
          : json['isAdmin'] as bool, // Ensure proper boolean parsing
    );
  }
}
