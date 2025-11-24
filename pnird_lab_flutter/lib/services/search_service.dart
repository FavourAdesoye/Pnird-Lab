import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class SearchService {
  static Future<Map<String, dynamic>> search(String query, {String? type}) async {
    try {
      String url = "${ApiService.baseUrl}/search?q=${Uri.encodeComponent(query)}";
      if (type != null && type != 'all') {
        url += "&type=$type";
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    try {
      if (query.trim().isEmpty || query.length < 2) {
        return [];
      }

      final url = "${ApiService.baseUrl}/search/suggestions?q=${Uri.encodeComponent(query)}";
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['suggestions'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      // Silently fail for suggestions - don't show errors to user
      return [];
    }
  }
}

