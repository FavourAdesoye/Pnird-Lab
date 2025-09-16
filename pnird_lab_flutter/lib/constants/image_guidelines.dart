class ImageGuidelines {
  // Post Image Standards
  static const int maxWidth = 800;
  static const int maxHeight = 600;
  static const int quality = 85;
  static const int maxFileSizeMB = 2;
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Display Dimensions
  static const double postImageHeight = 400.0;
  static const double profilePictureSize = 40.0;
  static const double thumbnailSize = 200.0;
  
  // Aspect Ratio Guidelines
  static const double preferredAspectRatio = 4.0 / 3.0; // 1.33:1
  static const double maxAspectRatio = 16.0 / 9.0; // 1.78:1
  static const double minAspectRatio = 1.0 / 1.0; // 1:1 (square)
  
  // Performance Guidelines
  static const int memoryCacheWidth = 800;
  static const int memoryCacheHeight = 600;
  static const int diskCacheMaxWidth = 800;
  static const int diskCacheMaxHeight = 600;
  
  // User Guidelines
  static const String userGuidelines = '''
📸 Image Guidelines for Posts:

✅ RECOMMENDED:
• Format: JPG, PNG, or WebP
• Size: Under 2MB
• Dimensions: 800x600px or similar aspect ratio
• Quality: High resolution, clear images
• Content: Relevant to your post

❌ AVOID:
• Very large files (>2MB)
• Blurry or low-quality images
• Inappropriate content
• Copyrighted material without permission

💡 TIPS:
• Use landscape orientation for better display
• Ensure good lighting
• Keep text readable if present
• Consider mobile viewing experience
  ''';
}

