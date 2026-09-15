import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import 'session_storage.dart';
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

  factory AuthResult.error(String message, {Map<String, dynamic>? data}) {
    return AuthResult(success: false, message: message, data: data);
  }
}

class Auth {
  static Future<void> _ensureFirebaseInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase Core is not initialized. No apps found.');
      }
      FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Firebase initialization check failed: $e');
      throw Exception(
        'Firebase is not properly initialized. Cannot proceed with authentication.',
      );
    }
  }

  /// Best-effort: remove a Firebase user created during a failed signup.
  static Future<void> _cleanupFailedSignup(User firebaseUser) async {
    try {
      await firebaseUser.delete();
    } catch (e) {
      debugPrint('Could not delete incomplete Firebase signup user: $e');
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    try {
      await SessionStorage.clearSession();
    } catch (_) {}
  }

  static String _friendlyRegisterError(int statusCode, Map<String, dynamic> errorData) {
    final serverMessage = errorData['message'] as String?;
    if (serverMessage != null && serverMessage.isNotEmpty) {
      if (statusCode == 403 && serverMessage.toLowerCase().contains('invite')) {
        return '$serverMessage\n\nYour account was not created. Ask a lab admin for the staff invite code and try again.';
      }
      if (statusCode == 409 && errorData['suggestions'] is List) {
        return serverMessage;
      }
      return serverMessage;
    }

    if (statusCode == 0 || statusCode >= 500) {
      return 'Could not reach the server to finish signup. Check your connection and that the app is pointing at the correct API, then try again.';
    }
    return 'Registration failed. Please try again.';
  }

  static Future<AuthResult> signUp(
    String email,
    String password,
    String username,
    String role, {
    String? inviteCode,
  }) async {
    User? firebaseUser;
    try {
      await _ensureFirebaseInitialized();

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.error('Registration failed. Please try again.');
      }

      await firebaseUser.sendEmailVerification();

      final firebaseUID = firebaseUser.uid;
      final trimmedInvite = inviteCode?.trim();

      http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(ApiService.registerEndpoint),
              headers: ApiService.headers,
              body: json.encode({
                'username': username,
                'email': email,
                'firebaseUID': firebaseUID,
                'role': role,
                if (trimmedInvite != null && trimmedInvite.isNotEmpty)
                  'inviteCode': trimmedInvite,
              }),
            )
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        await _cleanupFailedSignup(firebaseUser);
        return AuthResult.error(
          'Could not reach the server to finish signup. Check your connection / API URL and try again.',
        );
      } catch (_) {
        await _cleanupFailedSignup(firebaseUser);
        return AuthResult.error(
          'Could not reach the server to finish signup. Check your connection / API URL and try again.',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return AuthResult.success(data);
      }

      final errorData = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      await _cleanupFailedSignup(firebaseUser);

      return AuthResult.error(
        _friendlyRegisterError(response.statusCode, errorData),
        data: errorData,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } on TimeoutException {
      if (firebaseUser != null) {
        await _cleanupFailedSignup(firebaseUser);
      }
      return AuthResult.error('Connection timed out. Please try again.');
    } catch (e) {
      if (firebaseUser != null) {
        await _cleanupFailedSignup(firebaseUser);
      }
      return AuthResult.error('Registration failed. Please try again.');
    }
  }

  static Future<AuthResult> login(String email, String password) async {
    try {
      await _ensureFirebaseInitialized();

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.error('Login failed. Please try again.');
      }

      final firebaseUID = firebaseUser.uid;

      // Reload so verification status is fresh after the user clicks the email link
      await firebaseUser.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed == null || !refreshed.emailVerified) {
        // Keep session so they can resend verification; do not treat as fully logged in
        await SessionStorage.clearSession();
        return AuthResult.error(
          'Please verify your email before logging in. Open the link we sent, then try again. You can resend it from the verification screen after signup.',
        );
      }

      http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(ApiService.getUserRoleEndpoint),
              headers: await ApiService.authHeaders(),
              body: json.encode({'uid': firebaseUID}),
            )
            .timeout(const Duration(seconds: 10));
      } on TimeoutException {
        await FirebaseAuth.instance.signOut();
        await SessionStorage.clearSession();
        return AuthResult.error(
          'Could not reach the backend server. Check your connection and API URL.',
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return AuthResult.success(data);
      }

      final errorData = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      await FirebaseAuth.instance.signOut();
      await SessionStorage.clearSession();

      if (response.statusCode == 404) {
        return AuthResult.error(
          'No app account was found for this login. Signup may not have finished — try signing up again, or contact support if this email is stuck in Firebase.',
        );
      }

      return AuthResult.error(errorData['message'] as String? ?? 'Login failed');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } on TimeoutException {
      return AuthResult.error(
        'Could not connect to backend server. Please check your internet connection.',
      );
    } catch (e) {
      debugPrint('Login error: $e');
      if (e.toString().toLowerCase().contains('notinitialized')) {
        return AuthResult.error(
          'Firebase is not properly initialized. Please restart the app and try again.',
        );
      }
      return AuthResult.error('Login failed. Please try again.');
    }
  }

  static String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'email-already-in-use':
        return 'An account already exists with this email. Try logging in, or contact support if signup did not finish.';
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
      await SessionStorage.clearSession();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  static Future<bool> isLoggedIn() async {
    return SessionStorage.isLoggedIn();
  }

  static Future<void> saveLoginState(
    String userId,
    String username,
    String role,
    String profilePicture,
    String firebaseUID,
  ) async {
    await SessionStorage.saveLoginState(
      userId: userId,
      username: username,
      role: role,
      profilePicture: profilePicture,
      firebaseUID: firebaseUID,
    );
  }

  static Future<Map<String, String?>> getStoredUserData() async {
    return SessionStorage.getStoredUserData();
  }

  static Future<AuthResult> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AuthResult.error('No user logged in');
      }

      await user.sendEmailVerification();
      return AuthResult.success({'message': 'Verification email sent'});
    } catch (e) {
      return AuthResult.error('Failed to send verification email. Please try again.');
    }
  }

  static Future<bool> isEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Error checking email verification');
      return false;
    }
  }

  static Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _ensureFirebaseInitialized();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success({
        'message': 'If an account exists for that email, a password reset link has been sent.',
      });
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Could not send a password reset email right now.');
    }
  }

  static Future<AuthResult> resendVerificationEmail(String email) async {
    try {
      await _ensureFirebaseInitialized();
      // Prefer a fresh sign-in flow; password reset also lets users regain access.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success({
        'message': 'Password reset email sent. Use it to regain access, then verify your email after signing in.',
      });
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Could not resend verification email right now.');
    }
  }

  /// Deletes the signed-in user's full account via the API (Mongo + Firebase Auth).
  static Future<AuthResult> deleteAccount() async {
    try {
      await _ensureFirebaseInitialized();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AuthResult.error('You must be signed in to delete your account.');
      }

      // Force a fresh token so the server can verify and delete
      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        return AuthResult.error('Could not verify your session. Sign in again and retry.');
      }

      final response = await http.delete(
        Uri.parse(ApiService.deleteMyAccountEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await SessionStorage.clearSession();
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        return AuthResult.success({'message': 'Account deleted'});
      }

      String message = 'Could not delete account. Please try again.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] is String) {
          message = body['message'] as String;
        }
      } catch (_) {}
      return AuthResult.error(message);
    } catch (e) {
      return AuthResult.error('Could not delete account. Check your connection and try again.');
    }
  }

  static Future<String?> getUserId() async {
    final data = await SessionStorage.getStoredUserData();
    return data['userId'];
  }
}
