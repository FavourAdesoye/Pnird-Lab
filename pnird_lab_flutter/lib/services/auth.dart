import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
class Auth {
  // Static method for sign up
  static Future<Map<String, dynamic>> signUp(String email, String password, String fullName, String role) async {
    try {
      // Sign up user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Retrieve Firebase UID
      String firebaseUID = userCredential.user!.uid;

      // Send details to Node.js backend to create user in MongoDB
      var response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        body: {
          'username': fullName,
          'email': email,
          'firebaseUID': firebaseUID,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        print("User successfully registered in MongoDB!");
        return {'success': true, 'user': userCredential.user};
      } else {
        print("Failed to register user in MongoDB: ${response.body}");
        return {'success': false, 'error': 'Failed to register user in backend'};
      }
    } catch (e) {
      print("Error during sign-up: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // Static method for login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Firebase log-in
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Retrieve Firebase UID
      String firebaseUID = userCredential.user!.uid;

      // Optional: Use Firebase UID to retrieve user role and profile from backend
      var response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        body: {'firebaseUID': firebaseUID},
      );

      if (response.statusCode == 200) {
        print("User successfully logged in and role verified!");
        return {'success': true, 'user': userCredential.user};
      } else {
        print("Failed to retrieve user data: ${response.body}");
        return {'success': false, 'error': 'Failed to retrieve user data'};
      }
    } catch (e) {
      print("Error during log-in: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // Static method to save login state
  static Future<void> saveLoginState(String userId, String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  // Static method to check email verification
  static Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Static method to resend verification email
  static Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == email) {
        await user.sendEmailVerification();
        return {'success': true};
      } else {
        return {'success': false, 'error': 'User not found or email mismatch'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Static method for logout
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('role');
  }

  // Static method to get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Static method to delete user account
  static Future<void> delete(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    // First, delete data from MongoDB
    final db = await Db.create('mongodb+srv://<username>:<password>@<cluster-url>/<dbname>');
    await db.open();

    final userId = user?.uid; // Firebase UID
    final collection = db.collection('your_collection_name');

    await collection.deleteMany({'userId': userId});

    await db.close();

    // Then, delete the user from Firebase Auth
    await user?.delete();

    // Optionally, navigate the user back to a login/signup page
    Navigator.of(context).pushReplacement(MaterialPageRoute( builder: (context) =>  const ChooseAccountTypePage()));
  }

}
