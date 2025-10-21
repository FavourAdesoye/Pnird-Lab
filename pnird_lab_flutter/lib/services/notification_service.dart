// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<List<dynamic>> fetchNotifications(String userId) async {
    try {
      // Use a more flexible API URL - you may need to update this based on your deployment
      final baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
      // For iOS simulator use: 'http://localhost:3000'
      // For production use your actual server URL
      
      final response = await http.get(
        Uri.parse("$baseUrl/api/notifications/$userId"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // returns list of notifications
      } else {
        throw Exception("Failed to load notifications: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception("Network error: Please check your connection");
    }
  }
}
