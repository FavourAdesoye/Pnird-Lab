import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session fields stored in secure storage, with SharedPreferences mirror
/// so existing screens that read prefs keep working.
class SessionStorage {
  static const _secure = FlutterSecureStorage();

  static const _kLoggedIn = 'is_logged_in';
  static const _kUserId = 'userId';
  static const _kUsername = 'username';
  static const _kRole = 'role';
  static const _kProfilePicture = 'profile_picture';
  static const _kFirebaseId = 'firebaseId';
  static const _kIsAdmin = 'isAdmin';

  static Future<void> saveLoginState({
    required String userId,
    required String username,
    required String role,
    required String profilePicture,
    required String firebaseUID,
  }) async {
    final isStaff = role == 'staff';

    await Future.wait([
      _secure.write(key: _kLoggedIn, value: 'true'),
      _secure.write(key: _kUserId, value: userId),
      _secure.write(key: _kUsername, value: username),
      _secure.write(key: _kRole, value: role),
      _secure.write(key: _kProfilePicture, value: profilePicture),
      _secure.write(key: _kFirebaseId, value: firebaseUID),
      _secure.write(key: _kIsAdmin, value: isStaff.toString()),
    ]);

    // Mirror for legacy SharedPreferences readers
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kUserId, userId);
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kRole, role);
    await prefs.setString(_kProfilePicture, profilePicture);
    await prefs.setString(_kFirebaseId, firebaseUID);
    await prefs.setBool(_kIsAdmin, isStaff);
  }

  static Future<bool> isLoggedIn() async {
    final secure = await _secure.read(key: _kLoggedIn);
    if (secure != null) {
      return secure == 'true';
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  static Future<Map<String, String?>> getStoredUserData() async {
    final secureUserId = await _secure.read(key: _kUserId);
    if (secureUserId != null && secureUserId.isNotEmpty) {
      return {
        'userId': secureUserId,
        'username': await _secure.read(key: _kUsername),
        'role': await _secure.read(key: _kRole),
        'profile_picture': await _secure.read(key: _kProfilePicture),
        'firebaseId': await _secure.read(key: _kFirebaseId),
      };
    }

    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_kUserId),
      'username': prefs.getString(_kUsername),
      'role': prefs.getString(_kRole),
      'profile_picture': prefs.getString(_kProfilePicture),
      'firebaseId': prefs.getString(_kFirebaseId),
    };
  }

  /// Clears session keys only (keeps theme and other non-auth prefs).
  static Future<void> clearSession() async {
    await Future.wait([
      _secure.delete(key: _kLoggedIn),
      _secure.delete(key: _kUserId),
      _secure.delete(key: _kUsername),
      _secure.delete(key: _kRole),
      _secure.delete(key: _kProfilePicture),
      _secure.delete(key: _kFirebaseId),
      _secure.delete(key: _kIsAdmin),
    ]);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedIn);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUsername);
    await prefs.remove(_kRole);
    await prefs.remove(_kProfilePicture);
    await prefs.remove(_kFirebaseId);
    await prefs.remove(_kIsAdmin);
  }
}
