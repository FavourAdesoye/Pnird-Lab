import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/services/api_service.dart';

class ChatbotService {
  static Future<Map<String, dynamic>> getPrivacyConfig() async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.get(
      Uri.parse('$baseUrl/chatbot/privacy-config'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }
    // Sensible defaults if the server is unreachable
    return {
      'saveConversations': true,
      'retentionDays': 30,
      'maxMessages': 40,
    };
  }

  static String privacyNoticeText(Map<String, dynamic> config) {
    final saves = config['saveConversations'] == true;
    final days = config['retentionDays'] is int
        ? config['retentionDays'] as int
        : int.tryParse('${config['retentionDays']}') ?? 30;
    final maxMessages = config['maxMessages'] is int
        ? config['maxMessages'] as int
        : int.tryParse('${config['maxMessages']}') ?? 40;

    if (!saves) {
      return 'Chat replies are not saved on our servers. Do not share sensitive research or health information here.';
    }

    return 'Chat history is kept for $days days. Longer threads keep about the latest $maxMessages messages. Do not share sensitive research or health information here.';
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required List<Map<String, dynamic>> conversationHistory,
    String? userId,
    String? conversationId,
  }) async {
    final baseUrl = ApiService.baseUrl;
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/chat'),
      headers: await ApiService.authHeaders(),
      body: jsonEncode({
        'message': message,
        'conversationHistory': conversationHistory,
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
      headers: await ApiService.authHeaders(),
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
      headers: await ApiService.authHeaders(),
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
      headers: await ApiService.authHeaders(),
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
      headers: await ApiService.authHeaders(),
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update conversation title: ${response.statusCode}');
    }
  }
}
