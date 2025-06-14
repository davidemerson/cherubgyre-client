import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class RegisterService {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  RegisterService() : _apiClient = ApiClient();

  Future<bool> verifyInviteCode(String code) async {
    try {
      final response = await _apiClient.get('/invites/verify', queryParameters: {'code': code});
      return response.data['valid'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String inviteCode,
    required String normalPin,
    required String duressPin,
  }) async {
    try {
      final response = await _apiClient.post(
        '/users/register',
        data: {
          'invite_code': inviteCode,
          'normal_pin': normalPin,
          'duress_pin': duressPin,
        },
      );

      final userData = response.data;
      
      // Store sensitive data securely
      await _storage.write(key: 'userId', value: userData['id']);
      await _storage.write(key: 'normalPin', value: normalPin);
      await _storage.write(key: 'duressPin', value: duressPin);

      return userData;
    } catch (e) {
      rethrow;
    }
  }
} 