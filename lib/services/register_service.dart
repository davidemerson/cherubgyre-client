import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

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

      if (response['success'] == true) {
        // Store authentication token and user data securely
        await _storage.write(key: 'accessToken', value: response['token']);
        await _storage.write(key: 'normalPin', value: normalPin);
        await _storage.write(key: 'duressPin', value: duressPin);
        
        return response['user'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }
} 