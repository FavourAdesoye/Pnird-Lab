import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  Future<void> signUp(String email, String password, String username) async {
    try {
      // Sign up user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Retrieve Firebase UID
      String firebaseUID = userCredential.user!.uid;

      // Send details to Node.js backend to create user in MongoDB
      var response = await http.post(
        Uri.parse('http://your_backend_api.com/register'),
        body: {
          'username': username,
          'email': email,
          'firebaseUID': firebaseUID,
        },
      );

      if (response.statusCode == 200) {
        print("User successfully registered in MongoDB!");
      } else {
        print("Failed to register user in MongoDB: ${response.body}");
      }
    } catch (e) {
      print("Error during sign-up: $e");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Firebase log-in
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Retrieve Firebase UID
      String firebaseUID = userCredential.user!.uid;

      // Optional: Use Firebase UID to retrieve user role and profile from backend
      var response = await http.post(
        Uri.parse('http://your_backend_api.com/login'),
        body: {'firebaseUID': firebaseUID},
      );

      if (response.statusCode == 200) {
        print("User successfully logged in and role verified!");
      } else {
        print("Failed to retrieve user data: ${response.body}");
      }
    } catch (e) {
      print("Error during log-in: $e");
    }
  }
}

Future<void> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId'); // Remove only the userId
}
