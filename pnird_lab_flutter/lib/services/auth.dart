import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    this.message = '',
    this.data,
  });

  factory AuthResult.success(Map<String, dynamic> data) {
    return AuthResult(success: true, message: 'Success', data: data);
  }

  factory AuthResult.error(String message) {
    return AuthResult(success: false, message: message);
  }
}

class Auth {
  // Helper method to ensure Firebase is initialized
  static Future<void> _ensureFirebaseInitialized() async {
    try {
      debugPrint('🔍 Checking Firebase Core initialization...');
      
      // First, verify Firebase Core is initialized
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase Core is not initialized. No apps found.');
      }
      debugPrint('✅ Firebase Core initialized (${Firebase.apps.length} app(s))');
      
      // Then verify Firebase Auth instance can be accessed
      debugPrint('🔍 Checking Firebase Auth initialization...');
      final auth = FirebaseAuth.instance;
      
      // Access auth methods to verify it's functional
      debugPrint('✅ Firebase Auth instance accessible (currentUser: ${auth.currentUser?.uid ?? "none"})');
    } catch (e) {
      debugPrint('❌ CRITICAL: Firebase initialization check failed: $e');
      throw Exception('Firebase is not properly initialized. Cannot proceed with authentication. Error: $e');
    }
  }
  
  static Future<AuthResult> signUp(String email, String password, String username, String role) async {
    try {
      // Ensure Firebase is initialized
      await _ensureFirebaseInitialized();
      
      // First, create Firebase account and send verification email
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // Send email verification immediately
      await userCredential.user!.sendEmailVerification();
      
      // Get Firebase UID
      String firebaseUID = userCredential.user!.uid;

      // Now register with backend
      var response = await http.post(
        Uri.parse(ApiService.registerEndpoint),
        headers: ApiService.headers,
        body: json.encode({
          'username': username,
          'email': email,
          'firebaseUID': firebaseUID,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AuthResult.success(data);
      } else {
        // If backend registration fails, delete Firebase account
        await userCredential.user!.delete();
        final errorData = json.decode(response.body);
        return AuthResult.error(errorData['message'] ?? 'Registration failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  static Future<AuthResult> login(String email, String password) async {
    try {
      debugPrint('🔐 Starting login for: $email');
      
      // Ensure Firebase is initialized
      await _ensureFirebaseInitialized();
      
      debugPrint('🔐 Attempting Firebase sign in...');
      // Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint('✅ Firebase sign in successful');
      
      // Retrieve Firebase UID
      String firebaseUID = userCredential.user!.uid;
      debugPrint('🔐 Firebase UID: $firebaseUID');

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        debugPrint('❌ Email not verified');
        return AuthResult.error('Please verify your email before logging in. Check your inbox for a verification email.');
      }
      debugPrint('✅ Email verified');

      // Get user role from backend
      debugPrint('🔗 Checking ApiService...');
      final endpoint = ApiService.getUserRoleEndpoint;
      debugPrint('🔗 Endpoint: $endpoint');
      debugPrint('🔗 Request body: ${json.encode({'uid': firebaseUID})}');
      
      // Test ApiService access
      try {
        final baseUrl = ApiService.baseUrl;
        debugPrint('✅ ApiService.baseUrl: $baseUrl');
      } catch (e) {
        debugPrint('❌ ApiService error: $e');
        throw Exception('ApiService not working: $e');
      }
      
      debugPrint('🔗 About to make HTTP request...');
      
      var response = await http.post(
        Uri.parse(endpoint),
        headers: ApiService.headers,
        body: json.encode({'uid': firebaseUID}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: Could not reach backend');
        },
      );
      
      debugPrint('✅ HTTP request completed successfully');
      debugPrint('📡 Backend responded with status: ${response.statusCode}');
      debugPrint('📡 Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Login successful, user data received');
        return AuthResult.success(data);
      } else {
        final errorData = json.decode(response.body);
        debugPrint('❌ Backend error: ${errorData['message']}');
        return AuthResult.error(errorData['message'] ?? 'Login failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Login error: $e');
      
      // Handle NotInitializedError specifically
      if (e.toString().contains('notinitialized') || e.toString().contains('NotInitialized')) {
        return AuthResult.error('Firebase is not properly initialized. Please restart the app and try again.');
      }
      
      // Handle timeout or connection errors
      if (e.toString().contains('timeout') || e.toString().contains('Could not reach backend')) {
        return AuthResult.error('Could not connect to backend server. Please check your internet connection.');
      }
      
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  static String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> saveLoginState(String userId, String username, String role, String profilePicture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('role', role);
    await prefs.setString('profile_picture', profilePicture);
  }

  static Future<Map<String, String?>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'username': prefs.getString('username'),
      'role': prefs.getString('role'),
      'profile_picture': prefs.getString('profile_picture'),
    };
  }

  // Send email verification
  static Future<AuthResult> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AuthResult.error('No user logged in');
      }

      await user.sendEmailVerification();
      return AuthResult.success({'message': 'Verification email sent'});
    } catch (e) {
      return AuthResult.error('Failed to send verification email: $e');
    }
  }

  // Check email verification status
  static Future<bool> isEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No current user found');
        return false;
      }
      
      print('Checking verification for user: ${user.email}');
      print('Current verification status: ${user.emailVerified}');
      
      // Reload user to get latest verification status
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      final isVerified = refreshedUser?.emailVerified ?? false;
      
      print('After reload - verification status: $isVerified');
      return isVerified;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Resend verification email via Firebase Client SDK
  static Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      // Send password reset email as an alternative way to verify the email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return AuthResult.success({'message': 'Password reset email sent. Use this to verify your email.'});
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
