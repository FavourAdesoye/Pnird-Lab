import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/comment_model.dart';
import 'api_service.dart';

class CommentService {
  static String get apiUrl => '${ApiService.baseUrl}/comments';

  // Helper method to generate the URL for fetching comments based on entity type and ID
  String _getCommentsUrl(String entityType, String entityId) {
    return '$apiUrl/$entityType/$entityId';
  }

  // Helper method to generate the URL for creating a comment or reply based on entity type and ID
  String _getCreateCommentUrl(String entityType, String entityId) {
    return '$apiUrl/$entityType/$entityId';
  }

  // Helper method to generate the URL for creating a reply
  String _getCreateReplyUrl(String entityType, String commentId) {
    return '$apiUrl/$entityType/$commentId/reply';
  }

  // Fetch comments by entity type (post or study) and ID
  Future<List<Comment>> getComments(String entityType, String entityId) async {
    try {
      final response =
          await http.get(Uri.parse(_getCommentsUrl(entityType, entityId)));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((commentJson) => Comment.fromJson(commentJson)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error silently
      rethrow;
    }
  }

  // Create a new comment for a post or study
  Future<void> createComment(String entityType, String entityId,
      String username, String comment) async {
    final response = await http.post(
      Uri.parse(_getCreateCommentUrl(entityType, entityId)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'entityId': entityId,
        'username': username,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post comment: ${response.statusCode} - ${response.body}');
    }
  }

  // Create a reply to a specific comment
  Future<void> createReply(String entityType, String commentId, String username,
      String reply) async {
    final response = await http.post(
      Uri.parse(_getCreateReplyUrl(entityType, commentId)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'reply': reply,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post reply: ${response.statusCode} - ${response.body}');
    }
  }
}
