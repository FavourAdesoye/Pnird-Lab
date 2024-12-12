// lib/services/post_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post_model.dart';

Future<List<Post>> getPosts() async {
  List<Post> posts = [];

  var url = Uri.parse('http://10.0.2.2:3000/api/posts');

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
