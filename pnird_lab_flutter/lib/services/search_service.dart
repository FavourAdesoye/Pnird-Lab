import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'app_exception.dart';

class SearchService {
  static Future<Map<String, dynamic>> search(String query, {String? type}) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw const AppException('Please enter a search term.');
    }

    try {
      String url = '${ApiService.baseUrl}/search?q=${Uri.encodeComponent(trimmedQuery)}';
      if (type != null && type != 'all') {
        url += '&type=$type';
      }

      final response = await http
          .get(Uri.parse(url), headers: ApiService.headers)
          .timeout(const Duration(seconds: 12));

      final decoded = response.body.isNotEmpty ? json.decode(response.body) : <String, dynamic>{};

      if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (response.statusCode == 429) {
        throw const AppException('You are searching too quickly. Please wait a moment and retry.');
      }

      final message = decoded is Map<String, dynamic> ? decoded['message']?.toString() : null;
      throw AppException(message ?? 'Search failed. Please try again.');
    } on TimeoutException {
      throw const AppException('Search timed out. Please check your connection and try again.');
    } on FormatException {
      throw const AppException('Received an invalid search response from the server.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Search is temporarily unavailable.', debugDetails: e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 2) {
      return [];
    }

    try {
      final url = '${ApiService.baseUrl}/search/suggestions?q=${Uri.encodeComponent(trimmedQuery)}';
      final response = await http
          .get(Uri.parse(url), headers: ApiService.headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) {
        return [];
      }

      final suggestions = data['suggestions'];
      if (suggestions is! List) {
        return [];
      }

      return suggestions
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
