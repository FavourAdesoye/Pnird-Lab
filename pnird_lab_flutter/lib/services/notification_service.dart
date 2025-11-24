// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NotificationService {
  static Future<List<dynamic>> fetchNotifications(String userId) async {
    try {
      // Use centralized API service for consistent platform handling
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/notifications/$userId"),
        headers: ApiService.headers,
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

  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/notifications/$userId/unread/count"),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] as int? ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await http.patch(
        Uri.parse("${ApiService.baseUrl}/notifications/$notificationId/read"),
        headers: ApiService.headers,
      );
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      await http.patch(
        Uri.parse("${ApiService.baseUrl}/notifications/$userId/read-all"),
        headers: ApiService.headers,
      );
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await http.delete(
        Uri.parse("${ApiService.baseUrl}/notifications/$notificationId"),
        headers: ApiService.headers,
      );
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  static Future<void> markBroadcastAsSeen(String userId, String broadcastId) async {
    try {
      await http.patch(
        Uri.parse("${ApiService.baseUrl}/notifications/$userId/broadcast/$broadcastId/seen"),
        headers: ApiService.headers,
      );
    } catch (e) {
      print('Error marking broadcast as seen: $e');
    }
  }
}
