import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Simple local authentication for now
      String userId = 'local_${email.hashCode}';
      
      // Send details to Node.js backend to create user in MongoDB
      var response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/register'),
        body: {
          'username': fullName,
          'email': email,
          'password': password,
          'firebaseUID': userId,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        print("User successfully registered in MongoDB!");
        return AuthResult(
          success: true,
          data: {'userId': userId, 'role': role, 'local': true},
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
      // Simple local authentication
      String userId = 'local_${email.hashCode}';
      
      // Try to verify with backend
      try {
        var response = await http.post(
          Uri.parse('http://localhost:3000/api/auth/login'),
          body: {'firebaseUID': userId, 'email': email},
        );

        if (response.statusCode == 200) {
          print("User successfully logged in!");
          final responseData = json.decode(response.body);
          final userData = responseData['user'];
          return AuthResult(
            success: true,
            data: {
              'userId': userId, 
              'username': userData['username'],
              'email': userData['email'],
              'role': userData['role'],
              'local': true
            },
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
        // Still return success for local auth, but note backend issue
        return AuthResult(
          success: true,
          data: {'userId': userId, 'local': true, 'backendError': true},
          message: 'Logged in successfully (local mode), but some features may be limited',
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
    // For local auth, always return true
    return true;
  }

  // Static method to resend verification email
  static Future<AuthResult> resendVerificationEmail(String email) async {
    // For local auth, always return success
    return AuthResult(
      success: true,
      message: 'Email verification not required in local mode',
    );
  }

  // Static method for logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('profilePicture');
  }

  // Static method to get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Static method to delete user account
  static Future<void> delete(BuildContext context) async {
    // For local auth, just clear preferences and navigate
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate the user back to a login/signup page
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
