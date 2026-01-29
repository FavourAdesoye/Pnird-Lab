import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiService {
  static String get baseUrl {
    // If .env has API_BASE_URL set and not empty, use it (for physical device testing)
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Platform-specific URL handling using defaultTargetPlatform (safer than Platform)
    // Use these defaults for simulators/emulators
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator uses 10.0.2.2 to access host machine
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
        // iOS simulator uses 127.0.0.1 (localhost can have DNS resolution issues)
        return 'http://127.0.0.1:3000/api';
      default:
        // macOS, Windows, Linux, or other platforms
        return 'http://localhost:3000/api';
    }
  }
  
  static String get socketUrl {
    // If .env has SOCKET_URL set and not empty, use it (for physical device testing)
    final envUrl = dotenv.env['SOCKET_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Same platform-specific logic for socket
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:3000';
      default:
        return 'http://localhost:3000';
    }
  }
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  // User endpoints
  static String get registerEndpoint => '$baseUrl/users/register';
  static String get loginEndpoint => '$baseUrl/users/login';
  static String get getUserRoleEndpoint => '$baseUrl/users/getUserRole';
  static String getUserEndpoint(String firebaseUID) => '$baseUrl/users/$firebaseUID';
  static String getUserByIdEndpoint(String id) => '$baseUrl/users/id/$id';
  static String getEmailVerificationStatusEndpoint(String firebaseUID) => '$baseUrl/users/email-verification-status/$firebaseUID';
  static String get resendVerificationEndpoint => '$baseUrl/users/resend-verification';
  
  // Posts endpoints
  static String get postsEndpoint => '$baseUrl/posts';
  static String getPostEndpoint(String id) => '$baseUrl/posts/$id';
  static String getUserPostsEndpoint(String userId) => '$baseUrl/posts/user/id/$userId';
  static String likePostEndpoint(String id) => '$baseUrl/posts/$id/like';
  
  // Studies endpoints
  static String get studiesEndpoint => '$baseUrl/studies';
  static String getStudyEndpoint(String id) => '$baseUrl/studies/$id';
  
  // Events endpoints
  static String get eventsEndpoint => '$baseUrl/events';
  static String getEventEndpoint(String id) => '$baseUrl/events/$id';
  
  // Messages endpoints
  static String get messagesEndpoint => '$baseUrl/messages';
  
  // Notifications endpoints
  static String get notificationsEndpoint => '$baseUrl/notifications';
}
