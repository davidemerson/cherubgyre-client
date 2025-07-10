import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/environment_config.dart';
import '../core/utils/session_manager.dart';

class ApiClient {
  static ApiClient? _instance;
  static Dio? _dio;
  static bool _isInitializing = false;

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal();

  Dio get dio {
    if (_dio == null) {
      throw StateError('API Client not initialized. Call initialize() first.');
    }
    return _dio!;
  }

  /// Initialize the API client
  static Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    try {
      final baseUrl = await EnvironmentConfig.selectedServerUrl;
      debugPrint('API Client initialized with base URL: $baseUrl');
      
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.sendTimeout,
          headers: ApiConstants.defaultHeaders,
        ),
      );

      // Add interceptors (verbose logging only in debug mode)
      if (kDebugMode) {
        _dio!.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ));
      }

      // Add authentication interceptor
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token for authenticated requests
          if (!options.path.contains('/login') && 
              !options.path.contains('/register') && 
              !options.path.contains('/verify-invite')) {
            final token = await SessionManager.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle authentication errors
          if (error.response?.statusCode == 401) {
            await SessionManager.clearSession();
          }
          handler.next(error);
        },
      ));
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initializeDio() async {
    final baseUrl = await EnvironmentConfig.selectedServerUrl;
    debugPrint('API Client initialized with base URL: $baseUrl');
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: ApiConstants.defaultHeaders,
      ),
    );

    // Add interceptors (verbose logging only in debug mode)
    if (kDebugMode) {
      _dio?.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    // Add authentication interceptor
    _dio?.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token for authenticated requests
        if (!options.path.contains('/login') && 
            !options.path.contains('/register') && 
            !options.path.contains('/validate-invite')) {
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle authentication errors
        if (error.response?.statusCode == 401) {
          await SessionManager.clearSession();
        }
        handler.next(error);
      },
    ));
  }

  /// Reinitialize the API client with a new server URL
  static Future<void> reinitializeWithNewServer() async {
    EnvironmentConfig.clearCachedServerUrl();
    _dio = null;
    await initialize();
  }

  /// Central place to validate HTTP status and decode body.
  dynamic _processResponse(Response response) {
    // Accept 200 / 201 as success. Everything else is treated as error.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data; // may be Map, List, etc.
    }

    // Attempt to extract message from JSON body (if any).
    String message = 'API error: ${response.statusCode}';
    try {
      final json = _ensureJsonMap(response.data);
      final extracted = _extractMessage(json);
      if (extracted.isNotEmpty) message = extracted;
    } catch (_) {
      // ignore – fallback to generic.
    }
    throw Exception(message);
  }

  // Override thin HTTP helpers to always run through _processResponse.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters, options: options);
      return _processResponse(response);
    } on DioException catch (e) {
      // Extract the error message and throw as Exception
      final errorResult = _handleDioException(e);
      throw Exception(errorResult[ApiConstants.messageKey]);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final fullUrl = '${dio.options.baseUrl}$path';
      debugPrint('🌐 Full URL: $fullUrl');
      final response = await dio.post(path, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      // Extract the error message and throw as Exception
      final errorResult = _handleDioException(e);
      throw Exception(errorResult[ApiConstants.messageKey]);
    }
  }

  // =====================
  // Helper utilities
  // =====================

  /// Ensures that the provided [data] is returned as a JSON `Map<String, dynamic>`.
  ///
  /// The API might return JSON responses or plain text. This helper converts both 
  /// representations into a single, safe `Map<String, dynamic>` format.
  Map<String, dynamic> _ensureJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (e) {
        // If JSON parsing fails, treat the string as a plain text message
        debugPrint('🔍 Plain text response, wrapping in message field: "$data"');
        return {'message': data};
      }
    }
    throw const FormatException('Unexpected response format – expected JSON object or text');
  }

  /// Extracts a human-readable `message` from a typical API error/response body.
  /// Falls back to an empty string when no message-like field is present.
  String _extractMessage(Map<String, dynamic> json) {
    const candidateKeys = ['message', 'error', 'detail'];
    for (final k in candidateKeys) {
      if (json[k] != null && json[k].toString().trim().isNotEmpty) {
        return json[k].toString();
      }
    }
    return '';
  }

  /// Predefined friendly messages per HTTP status.
  static const Map<int, String> _statusCodeMessages = {
    400: 'Bad request. Please verify the submitted data.',
    401: 'Unauthorized. Please log in again.',
    402: 'Payment required to complete this request.',
    403: 'Forbidden. You don\'t have permission to perform this action.',
    404: 'Not found. The requested resource does not exist.',
    405: 'Method not allowed on this endpoint.',
    409: 'Conflict. The resource already exists or there\'s a version mismatch.',
    410: 'Gone. The resource requested is no longer available.',
    413: 'Payload too large. Please reduce the request size.',
    415: 'Unsupported media type. Check your Content-Type header.',
    422: 'Unprocessable entity. Validation failed on the server.',
    429: 'Too many requests. Please slow down.',
    500: 'Server error. Please try again later.',
    501: 'Not implemented on the server.',
    502: 'Bad gateway. Upstream service failure.',
    503: 'Service unavailable. Please try again later.',
    504: 'Gateway timeout. The server took too long to respond.',
  };

  /// Converts a Dio error into a uniform error payload the UI can consume.
  Map<String, dynamic> _handleDioException(DioException e, {String defaultMessage = 'Network error. Please try again.'}) {
    String errorMessage = defaultMessage;

    debugPrint('🔍 DioException details:');
    debugPrint('  - Status: ${e.response?.statusCode}');
    debugPrint('  - Content-Type: ${e.response?.headers['content-type']}');
    debugPrint('  - Response data: ${e.response?.data}');
    debugPrint('  - Response data type: ${e.response?.data.runtimeType}');

    // Attempt to parse server-provided error body first.
    if (e.response?.data != null) {
      try {
        final parsed = _ensureJsonMap(e.response!.data);
        final serverMsg = _extractMessage(parsed);
        if (serverMsg.isNotEmpty) {
          errorMessage = serverMsg;
          debugPrint('🔍 Extracted server message: "$errorMessage"');
        }
      } catch (parseError) {
        debugPrint('⚠️ Failed to parse response data: $parseError');
        // If parsing fails completely, try to use raw data as string
        if (e.response!.data is String) {
          errorMessage = e.response!.data.toString();
          debugPrint('🔍 Using raw string as error message: "$errorMessage"');
        }
      }
    }

    // If still generic, map using status-code dictionary.
    if (errorMessage == defaultMessage && e.response?.statusCode != null) {
      errorMessage = _statusCodeMessages[e.response!.statusCode!] ?? errorMessage;
      debugPrint('🔍 Using status code message: "$errorMessage"');
    }

    // If still generic, refine based on Dio type.
    if (errorMessage == defaultMessage) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please check your Internet connection.';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Bad SSL certificate from server.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection. Please check your network.';
          break;
        default:
          break; // keep default message.
      }
    }

    // Fallback to Dio's own message if still default.
    if (errorMessage == defaultMessage && e.message != null) {
      errorMessage = e.message!;
    }

    debugPrint('🚫 Error resolved to message: "$errorMessage" (status ${e.response?.statusCode})');
    return {ApiConstants.successKey: false, ApiConstants.messageKey: errorMessage};
  }

  // Login method
  Future<Map<String, dynamic>> login({required String username, required String pin}) async {
    try {
      debugPrint('🌐 Making login request to: ${ApiConstants.loginEndpoint}');
      debugPrint('📤 Request data: {username: "$username", pin: "$pin"}');
      
      final dynamic raw = await post(ApiConstants.loginEndpoint, data: {
        'username': username,
        'pin': pin,
      });
      
      debugPrint('✅ Login request successful – parsing JSON');
      final responseData = _ensureJsonMap(raw);
      
      debugPrint('📥 Parsed response JSON: $responseData');
      
      // Store authentication data securely
      if (responseData[ApiConstants.tokenKey] != null) {
        await SessionManager.storeToken(responseData[ApiConstants.tokenKey]);
        
        // Store user data including avatar if available
        final userData = responseData[ApiConstants.userKey] as Map<String, dynamic>?;
        final avatar = userData?[ApiConstants.avatarKey];
        
        await SessionManager.storeUserData({
          'username': username,
          'avatar': avatar,
        });
        await SessionManager.storeLastLogin();
        
        debugPrint('🔐 Session data stored successfully');
        debugPrint('🔐 Stored username: $username, avatar: $avatar');
      }
      
      return {
        ApiConstants.successKey: true,
        ApiConstants.tokenKey: responseData[ApiConstants.tokenKey],
        ApiConstants.userKey: responseData[ApiConstants.userKey],
      };
    } catch (e, st) {
      debugPrint('💥 Exception in login: $e\n$st');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Login method without session storage (for registration auto-login)
  Future<Map<String, dynamic>> loginWithoutSessionStorage({required String username, required String pin}) async {
    try {
      debugPrint('🌐 Making login request to: ${ApiConstants.loginEndpoint} (without session storage)');
      debugPrint('📤 Request data: {username: "$username", pin: "$pin"}');
      
      final dynamic raw = await post(ApiConstants.loginEndpoint, data: {
        'username': username,
        'pin': pin,
      });
      
      debugPrint('✅ Login request successful – parsing JSON');
      final responseData = _ensureJsonMap(raw);
      
      debugPrint('📥 Parsed response JSON: $responseData');
      
      // Don't store session data - let caller handle it
      debugPrint('🔐 Login successful but session storage skipped (will be handled by caller)');
      
      return {
        ApiConstants.successKey: true,
        ApiConstants.tokenKey: responseData[ApiConstants.tokenKey],
        ApiConstants.userKey: responseData[ApiConstants.userKey],
      };
    } catch (e, st) {
      debugPrint('💥 Exception in loginWithoutSessionStorage: $e\n$st');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Validate invite code method
  Future<bool> verifyInviteCode(String inviteCode) async {
    try {
      debugPrint('🌐 Making invite validation request to: ${ApiConstants.validateInviteEndpoint}');
      debugPrint('📤 Request data: {invite_code: "$inviteCode"}');
      
      final response = await post(ApiConstants.validateInviteEndpoint, data: {
        'invite_code': inviteCode,
      });
      final data = _ensureJsonMap(response);
      debugPrint('✅ Invite validation response: $data');
      return data[ApiConstants.validKey] == true;
    } catch (e) {
      debugPrint('❌ Invite code validation failed: $e');
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
      debugPrint('🌐 Making register request to: ${ApiConstants.registerEndpoint}');
      debugPrint('📤 Request data: {invite_code: "$inviteCode", normal_pin: "${normalPin.length} chars", duress_pin: "${duressPin.length} chars"}');
      
      final response = await post(ApiConstants.registerEndpoint, data: {
        ApiConstants.inviteCodeKey: inviteCode,
        ApiConstants.normalPinKey: normalPin,
        ApiConstants.duressPinKey: duressPin,
      });
      
      final responseData = _ensureJsonMap(response);
      debugPrint('📥 Parsed registration response: $responseData');
      
      // Extract user data from the nested 'user' object
      final userData = responseData['user'] as Map<String, dynamic>?;
      debugPrint('📥 Extracted user data: $userData');
      
      // Store user data securely if registration includes authentication
      if (responseData[ApiConstants.tokenKey] != null) {
        await SessionManager.storeToken(responseData[ApiConstants.tokenKey]);
        await SessionManager.storeUserData({
          'username': userData?[ApiConstants.usernameKey],
          'avatar': userData?[ApiConstants.avatarKey],
        });
        await SessionManager.storeLastLogin();
      }
      
      return {
        ApiConstants.successKey: true,
        ApiConstants.userKey: {
          ApiConstants.idKey: userData?[ApiConstants.idKey],
          ApiConstants.usernameKey: userData?[ApiConstants.usernameKey],
          ApiConstants.avatarKey: userData?[ApiConstants.avatarKey],
        },
      };
    } catch (e) {
      debugPrint('💥 Exception in register: $e');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Profile method
  Future<Map<String, dynamic>> getProfile() async {
    try {
      debugPrint('🌐 Making profile request to: ${ApiConstants.profileEndpoint}');
      
      // The authentication interceptor will automatically add the Authorization header
      final response = await get(ApiConstants.profileEndpoint);
      final responseData = _ensureJsonMap(response);
      
      debugPrint('📥 Parsed profile response: $responseData');
      
      return {
        ApiConstants.successKey: true,
        ApiConstants.userKey: {
          ApiConstants.idKey: responseData[ApiConstants.idKey],
          ApiConstants.usernameKey: responseData[ApiConstants.usernameKey],
          ApiConstants.avatarKey: responseData[ApiConstants.avatarKey],
        },
      };
    } catch (e) {
      debugPrint('💥 Exception in getProfile: $e');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Call logout endpoint if available
      await post('/logout');
    } catch (e) {
      // Ignore errors on logout
      debugPrint('Logout API error: $e');
    } finally {
      // Always clear local session
      await SessionManager.clearSession();
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