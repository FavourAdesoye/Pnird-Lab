/// Publication model to represent research publications
class Publication {
  final String title;
  final String pdfPath;
  final String? journal;
  final int? year;
  final List<String>? authors;

  Publication({
    required this.title,
    required this.pdfPath,
    this.journal,
    this.year,
    this.authors,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      title: json['title'],
      pdfPath: json['pdfPath'],
      journal: json['journal'],
      year: json['year'],
      authors: json['authors'] != null ? List<String>.from(json['authors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pdfPath': pdfPath,
      'journal': journal,
      'year': year,
      'authors': authors,
    };
  }
}

/// Team Member model to represent lab members with their information
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String bio;
  final String profileImage;
  final String email;
  final String? linkedin;
  final String? twitter;
  final String? github;
  final String? website;
  final String? cvUrl;
  final List<String> specializations;
  final String department;
  final List<Publication> publications;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.profileImage,
    required this.email,
    this.linkedin,
    this.twitter,
    this.github,
    this.website,
    this.cvUrl,
    required this.specializations,
    required this.department,
    required this.publications,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      email: json['email'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      github: json['github'],
      website: json['website'],
      cvUrl: json['cvUrl'],
      specializations: List<String>.from(json['specializations'] ?? []),
      department: json['department'],
      publications: (json['publications'] as List<dynamic>?)
          ?.map((pub) => Publication.fromJson(pub))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'bio': bio,
      'profileImage': profileImage,
      'email': email,
      'linkedin': linkedin,
      'twitter': twitter,
      'github': github,
      'website': website,
      'cvUrl': cvUrl,
      'specializations': specializations,
      'department': department,
      'publications': publications.map((pub) => pub.toJson()).toList(),
    };
  }
}
