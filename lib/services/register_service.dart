import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../core/constants/api_constants.dart';

class RegisterService {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  RegisterService() : _apiClient = ApiClient();

  Future<bool> verifyInviteCode(String code) async {
    try {
      return await _apiClient.verifyInviteCode(code);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String inviteCode,
    required String normalPin,
    required String duressPin,
  }) async {
    try {
      final response = await _apiClient.register(
        inviteCode: inviteCode,
        normalPin: normalPin,
        duressPin: duressPin,
      );

      if (response[ApiConstants.successKey] == true) {
        // Store user data securely (no token in registration response)
        await _storage.write(key: 'normalPin', value: normalPin);
        await _storage.write(key: 'duressPin', value: duressPin);
        
        // Store server-assigned username for future logins
        final userData = response[ApiConstants.userKey] as Map<String, dynamic>?;
        if (userData != null && userData[ApiConstants.usernameKey] != null) {
          await _storage.write(key: 'username', value: userData[ApiConstants.usernameKey]);
        }
        
        return userData ?? {};
      } else {
        throw Exception(response[ApiConstants.messageKey] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }
} 