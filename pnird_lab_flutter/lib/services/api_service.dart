import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  }
  
  static String get socketUrl {
    return dotenv.env['SOCKET_URL'] ?? 'http://localhost:3000';
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
