import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  // Standard post image dimensions
  static const int maxWidth = 800;
  static const int maxHeight = 600;
  static const int quality = 85; // JPEG quality (0-100)
  
  // Allowed formats
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Maximum file size (2MB)
  static const int maxFileSizeBytes = 2 * 1024 * 1024;

  /// Process and resize image for posts
  static Future<File?> processPostImage(File imageFile) async {
    try {
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception('Image too large. Maximum size is 2MB.');
      }

      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Invalid image format');
      }

      // Calculate new dimensions while maintaining aspect ratio
      final aspectRatio = image.width / image.height;
      int newWidth = maxWidth;
      int newHeight = maxHeight;

      if (aspectRatio > 1) {
        // Landscape
        newHeight = (maxWidth / aspectRatio).round();
        if (newHeight > maxHeight) {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      } else {
        // Portrait or square
        newWidth = (maxHeight * aspectRatio).round();
        if (newWidth > maxWidth) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        }
      }

      // Resize image
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to JPEG for consistency
      final jpegBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/processed_post_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(jpegBytes);
      
      return tempFile;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > maxFileSizeBytes) {
        return false;
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!allowedFormats.contains(extension)) {
        return false;
      }

      // Try to decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      return image != null;
    } catch (e) {
      return false;
    }
  }

  /// Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        return {
          'width': image.width,
          'height': image.height,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create thumbnail for preview
  static Future<Uint8List?> createThumbnail(File imageFile, {int size = 200}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Create square thumbnail
      final thumbnail = img.copyResizeCropSquare(image, size);
      final jpegBytes = img.encodeJpg(thumbnail, quality: 80);
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      return null;
    }
  }
}
