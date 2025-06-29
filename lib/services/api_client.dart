import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.example.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Login method
  Future<Map<String, dynamic>> login({required String username, required String pin}) async {
    try {
      final response = await post('/auth/login', data: {
        'username': username,
        'pin': pin,
      });
      
      return {
        'success': true,
        'token': response.data['token'],
        'user': response.data['user'],
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Verify invite code method
  Future<bool> verifyInviteCode(String inviteCode) async {
    try {
      final response = await post('/auth/verify-invite', data: {
        'inviteCode': inviteCode,
      });
      
      return response.data['valid'] == true;
    } catch (e) {
      return false;
    }
  }

  // Register method
  Future<Map<String, dynamic>> register({
    required String inviteCode,
    required String normalPin,
    required String duressPin,
  }) async {
    try {
      final response = await post('/auth/register', data: {
        'inviteCode': inviteCode,
        'normalPin': normalPin,
        'duressPin': duressPin,
      });
      
      return {
        'success': true,
        'token': response.data['token'],
        'user': response.data['user'],
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'An error occurred';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
} 