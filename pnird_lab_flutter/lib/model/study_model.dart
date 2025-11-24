class Study {
  final String id;
  final String imageUrl;
  final String description;
  final String titlePost;
  final DateTime createdAt;
  final DateTime updatedAt;

  Study({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.titlePost,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Study from JSON
  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: json['_id'],
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      titlePost: json['titlepost'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
    );
  }

  // Convert a Study object to JSON (optional, for creating/editing)
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'description': description,
      'titlepost': titlePost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
