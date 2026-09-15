import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/services/api_service.dart';

Future<void> likePost(String postId, String userId) async {
  final response = await http.put(
    Uri.parse('${ApiService.baseUrl}/posts/$postId/like'),
    body: jsonEncode({}),
    headers: await ApiService.authHeaders(),
  );

  if (response.statusCode == 200) {
    print('Post liked/disliked successfully');
  } else {
    print('Failed to like/dislike post: ${response.statusCode}');
  }
}
