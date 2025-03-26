import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class UserService {
  static const String apiUrl = 'http://localhost:3000/api/users/id/';

  Future<User> fetchUserProfile(String userId) async {
    final response = await http.get(Uri.parse('$apiUrl$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile data');
    }
  }
}
