import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../core/constants/api_constants.dart';

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
        if (userData != null && userData[ApiConstants.usernameKey] != null) {
          await _storage.write(key: 'username', value: userData[ApiConstants.usernameKey]);
          if (kDebugMode) {
            debugPrint('🔍 RegisterService: Stored username: ${userData[ApiConstants.usernameKey]}');
          }
        }
        
        return userData ?? {};
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