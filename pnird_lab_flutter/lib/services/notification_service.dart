// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<List<dynamic>> fetchNotifications(String userId) async {
    final response = await http.get(
      Uri.parse("http://localhost:3000/api/notifications/$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // returns list of notifications
    } else {
      throw Exception("Failed to load notifications");
    }
  }
}
