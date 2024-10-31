import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post_model.dart';
import '../model/comment_model.dart';

class CommentService {
  static const String apiUrl =
      'http://localhost:3000/api/comments'; // Replace with your API URL

  // Fetch comments by post ID
  Future<List<Comment>> getCommentsByPost(String postId) async {
    final response = await http.get(Uri.parse('$apiUrl/$postId/getComments'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Create a new comment
  Future<void> createComment(
      String postId, String username, String comment) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$postId/createComment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'postId': postId,
        'username': username,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post comment');
    }
  }

  //replies
  Future<void> createReply(
      String commentId, String username, String reply) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$commentId/replies'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'reply': reply,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post reply');
    }
  }
}
