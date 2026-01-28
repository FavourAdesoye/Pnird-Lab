import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/services/api_service.dart';

class ChatbotService {
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required List<Map<String, dynamic>> conversationHistory,
    String? userId,
    String? conversationId,
  }) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'conversationHistory': conversationHistory,
        if (userId != null) 'userId': userId,
        if (conversationId != null) 'conversationId': conversationId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.get(
      Uri.parse('$baseUrl/chatbot/conversations/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['conversations'] ?? []);
    } else {
      throw Exception('Failed to fetch conversations: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getConversation(String userId, String conversationId) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.get(
      Uri.parse('$baseUrl/chatbot/conversations/$userId/$conversationId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch conversation: ${response.statusCode}');
    }
  }

  static Future<void> deleteConversation(String userId, String conversationId) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.delete(
      Uri.parse('$baseUrl/chatbot/conversations/$userId/$conversationId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation: ${response.statusCode}');
    }
  }

  static Future<void> updateConversationTitle(
    String userId,
    String conversationId,
    String title,
  ) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.patch(
      Uri.parse('$baseUrl/chatbot/conversations/$userId/$conversationId/title'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update conversation title: ${response.statusCode}');
    }
  }
}


