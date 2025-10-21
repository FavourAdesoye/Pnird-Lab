import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    this.message = '',
    this.data,
  });
}

class Auth {
  // Static method for sign up
  static Future<AuthResult> signUp(String email, String password, String fullName, String role) async {
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
        return AuthResult(
          success: true,
          data: {'user': userCredential.user, 'userId': firebaseUID, 'role': role},
        );
      } else {
        print("Failed to register user in MongoDB: ${response.body}");
        return AuthResult(
          success: false,
          message: 'Failed to register user in backend',
        );
      }
    } catch (e) {
      print("Error during sign-up: $e");
      return AuthResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Static method for login
  static Future<AuthResult> login(String email, String password) async {
    try {
      // Firebase log-in with better error handling
      UserCredential userCredential;
      try {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } catch (firebaseError) {
        print("Firebase Auth Error: $firebaseError");
        // Handle specific Firebase errors
        if (firebaseError.toString().contains('PigeonUserDetails')) {
          return AuthResult(
            success: false,
            message: 'Authentication service temporarily unavailable. Please try again.',
          );
        }
        return AuthResult(
          success: false,
          message: 'Invalid email or password. Please check your credentials.',
        );
      }

      // Retrieve Firebase UID
      String firebaseUID = userCredential.user?.uid ?? '';

      if (firebaseUID.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Failed to retrieve user information.',
        );
      }

      // Optional: Use Firebase UID to retrieve user role and profile from backend
      try {
        var response = await http.post(
          Uri.parse('http://localhost:3000/login'),
          body: {'firebaseUID': firebaseUID},
        );

        if (response.statusCode == 200) {
          print("User successfully logged in and role verified!");
          return AuthResult(
            success: true,
            data: {'user': userCredential.user, 'userId': firebaseUID},
          );
        } else {
          print("Failed to retrieve user data: ${response.body}");
          return AuthResult(
            success: false,
            message: 'Failed to retrieve user data from server',
          );
        }
      } catch (backendError) {
        print("Backend Error: $backendError");
        // Still return success for Firebase auth, but note backend issue
        return AuthResult(
          success: true,
          data: {'user': userCredential.user, 'userId': firebaseUID, 'backendError': true},
          message: 'Logged in successfully, but some features may be limited',
        );
      }
    } catch (e) {
      print("Error during log-in: $e");
      return AuthResult(
        success: false,
        message: 'Login failed. Please try again.',
      );
    }
  }

  // Static method to save login state
  static Future<void> saveLoginState(String userId, String email, String role, [String? profilePicture]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    if (profilePicture != null) {
      await prefs.setString('profilePicture', profilePicture);
    }
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
  static Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == email) {
        await user.sendEmailVerification();
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          message: 'User not found or email mismatch',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: e.toString(),
      );
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

  // Instance methods for Provider compatibility
  Future<void> deleteAccount(BuildContext context) async {
    await Auth.delete(context);
  }

  Future<void> logoutUser() async {
    await Auth.logout();
  }

}
