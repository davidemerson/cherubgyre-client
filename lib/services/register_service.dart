import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/session_manager.dart';

class RegisterService {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  RegisterService() : _apiClient = ApiClient();

  Future<bool> verifyInviteCode(String code) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 RegisterService: Verifying invite code: $code');
      }
      final result = await _apiClient.verifyInviteCode(code);
      if (kDebugMode) {
        debugPrint('🔍 RegisterService: Invite code verification result: $result');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 RegisterService: Exception during invite code verification: $e');
        debugPrint('💥 RegisterService: Exception type: ${e.runtimeType}');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String inviteCode,
    required String normalPin,
    required String duressPin,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 RegisterService: Starting registration...');
        debugPrint('🔍 RegisterService: Invite code: $inviteCode');
        debugPrint('🔍 RegisterService: Normal PIN length: ${normalPin.length}');
        debugPrint('🔍 RegisterService: Duress PIN length: ${duressPin.length}');
      }

      final response = await _apiClient.register(
        inviteCode: inviteCode,
        normalPin: normalPin,
        duressPin: duressPin,
      );

      if (kDebugMode) {
        debugPrint('🔍 RegisterService: API response: $response');
      }

      if (response[ApiConstants.successKey] == true) {
        if (kDebugMode) {
          debugPrint('🔍 RegisterService: Registration successful, storing data...');
        }
        // Store user data securely (no token in registration response)
        await _storage.write(key: 'normalPin', value: normalPin);
        await _storage.write(key: 'duressPin', value: duressPin);

        // Store server-assigned username for future logins
        final userData = response[ApiConstants.userKey] as Map<String, dynamic>?;
        String? username;
        String? avatar;
        
        if (userData != null) {
          username = userData[ApiConstants.usernameKey] as String?;
          avatar = userData[ApiConstants.avatarKey] as String?;
          
          if (username != null) {
            await _storage.write(key: 'username', value: username);
            if (kDebugMode) {
              debugPrint('🔍 RegisterService: Stored username: $username');
              debugPrint('🔍 RegisterService: Avatar from registration: $avatar');
            }
          }
        }

        // --- NEW: Automatically log in after registration to obtain auth token ---
        if (username != null) {
          // Call login API but don't let it store session data (we'll do it manually)
          final loginResponse = await _apiClient.loginWithoutSessionStorage(username: username, pin: normalPin);
          if (loginResponse[ApiConstants.successKey] == true) {
            if (kDebugMode) {
              debugPrint('🔍 RegisterService: Auto-login after registration successful.');
            }
            
            // Manually store session data with avatar from registration
            await SessionManager.storeToken(loginResponse[ApiConstants.tokenKey]);
            
            final userDataToStore = {
              'username': username,
              'avatar': avatar,
            };
            
            if (kDebugMode) {
              debugPrint('🔍 RegisterService: About to store user data: $userDataToStore');
            }
            
            await SessionManager.storeUserData(userDataToStore);
            await SessionManager.storeLastLogin();
            
            // Verify the data was stored correctly
            final storedData = await SessionManager.getUserData();
            if (kDebugMode) {
              debugPrint('🔍 RegisterService: Verification - stored user data: $storedData');
              debugPrint('🔍 RegisterService: Username: $username, Avatar: $avatar');
            }
            
            // Return both userData and token
            return {
              ...?userData,
              ApiConstants.tokenKey: loginResponse[ApiConstants.tokenKey],
            };
          } else {
            if (kDebugMode) {
              debugPrint('❌ RegisterService: Auto-login after registration failed: ${loginResponse[ApiConstants.messageKey]}');
            }
            throw Exception('Registration succeeded but login failed: ${loginResponse[ApiConstants.messageKey]}');
          }
        } else {
          throw Exception('Registration succeeded but username missing for login.');
        }
      } else {
        final errorMessage = response[ApiConstants.messageKey] ?? 'Registration failed';
        if (kDebugMode) {
          debugPrint('❌ RegisterService: Registration failed: $errorMessage');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 RegisterService: Exception during registration: $e');
        debugPrint('💥 RegisterService: Exception type: ${e.runtimeType}');
      }
      rethrow;
    }
  }
} 