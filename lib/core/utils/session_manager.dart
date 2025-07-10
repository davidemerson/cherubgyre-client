import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Secure session manager for handling authentication tokens and user sessions
class SessionManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Private constructor to prevent instantiation
  SessionManager._();

  /// Store authentication token securely
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  /// Retrieve authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Store user data securely
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    // Store only non-sensitive user data
    final safeData = <String, dynamic>{};
    
    if (userData.containsKey('username')) {
      safeData['username'] = userData['username'];
    }
    if (userData.containsKey('avatar')) {
      safeData['avatar'] = userData['avatar'];
    }
    if (userData.containsKey('userId')) {
      safeData['userId'] = userData['userId'];
    }
    
    // Convert to JSON string for storage using proper JSON serialization
    final jsonString = jsonEncode(safeData);
    await _storage.write(key: 'userData', value: jsonString);
  }

  /// Retrieve user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: 'userData');
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error parsing user data JSON: $e');
        return null;
      }
    }
    return null;
  }

  /// Clear all session data (logout)
  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  /// Store last login timestamp
  static Future<void> storeLastLogin() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: 'lastLogin', value: timestamp);
  }

  /// Get last login timestamp
  static Future<DateTime?> getLastLogin() async {
    final timestamp = await _storage.read(key: 'lastLogin');
    if (timestamp != null) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      } catch (e) {
        debugPrint('Error parsing last login timestamp: $e');
        return null;
      }
    }
    return null;
  }

  /// Check if session has expired (optional feature)
  static Future<bool> isSessionExpired({Duration maxAge = const Duration(days: 30)}) async {
    final lastLogin = await getLastLogin();
    if (lastLogin == null) {
      return true;
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    return difference > maxAge;
  }
} 