import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> likePost(String postId, String userId) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:3000/api/posts/$postId/like'),
    body: jsonEncode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Post liked/disliked successfully');
  } else {
    print('Failed to like/dislike post');
  }
}
