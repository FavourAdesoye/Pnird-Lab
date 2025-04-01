// lib/services/post_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post_model.dart';

Future<List<Post>> getPosts() async {
  List<Post> posts = [];

  var url = Uri.parse('http://localhost:3000/api/posts');

  try {
    final res = await http.get(url);

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);

      if (data != null && data is List) {
        posts = data.map((postJson) => Post.fromJson(postJson)).toList();
      }

      return posts;
    } else {
      throw Exception('Failed to load posts: ${res.statusCode}');
    }
  } catch (e) {
    print('Error fetching posts: $e');
    throw Exception('Failed to load posts: $e');
  }
}

// class PostService{
//   static const String apiUrl = 'http://localhost:3000/api/posts/user/';

//   Future<List<Post>> fetchUserPosts(String userId) async {
//     final response = await http.get(Uri.parse('$apiUrl$userId'));
//     if(response.statusCode == 200){
//       List<dynamic> jsonResponse = json.decode(response.body);
//       return jsonResponse.map((postJson) => Post.fromJson(postJson)).toList();
//     } else {
//       throw Exception('Failed to load user posts');
//     }
//   }
// }

//get post2 fetches user post based on user id. not firebase id
class PostService2 {
  static const String apiUrl = 'http://localhost:3000/api/posts/user/id/';

  Future<List<Post>> fetchUserPosts(String userId) async {
    print("Fetching posts for User ID: $userId");

    final response = await http.get(Uri.parse('$apiUrl$userId'));

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
  final data = json.decode(response.body);

  if (data is List) {
    return data.map((postJson) => Post.fromJson(postJson)).toList();
  } else {
    print("Unexpected response format: $data");
    throw Exception("Expected a list but got something else");
  }
}else {
      throw Exception('Failed to load user posts');
    }
  }
}
