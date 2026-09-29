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
      id: json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      // Public feeds omit email on purpose; only self/profile endpoints include it.
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      firebaseUID: json['firebaseUID']?.toString() ?? '',
      isAdmin: json['isAdmin'] == null
          ? null
          : json['isAdmin'] as bool, // Ensure proper boolean parsing
      role: json['role'] as String?,
    );
  }
}
