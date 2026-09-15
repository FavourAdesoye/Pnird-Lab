class Study {
  final String id;
  final String imageUrl;
  final String description;
  final String titlePost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? formLink; // Optional form link for Google/Microsoft Forms

  Study({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.titlePost,
    required this.createdAt,
    required this.updatedAt,
    this.formLink,
  });

  // Factory constructor to create a Study from JSON
  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: json['_id']?.toString() ?? '',
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '') as String,
      description: json['description']?.toString() ?? '',
      titlePost: (json['titlepost'] ?? json['titlePost'] ?? 'Untitled Study') as String,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      formLink: json['formLink'] as String?,
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
      'formLink': formLink,
    };
  }
}
