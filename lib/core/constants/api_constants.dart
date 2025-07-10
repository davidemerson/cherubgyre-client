/// API configuration constants for CherubGyre application
class ApiConstants {
  // Base URL for all API endpoints
  static const String baseUrl = 'https://cherubgyre-dev-53de84d03c61.herokuapp.com';
  
  // API version
  static const String apiVersion = '/v1';
  
  // Authentication endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String validateInviteEndpoint = '/validate-invite';
  static const String profileEndpoint = '/profile';
  
  // Response keys
  static const String successKey = 'success';
  static const String messageKey = 'message';
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String validKey = 'valid';
  
  // Request keys
  static const String usernameKey = 'username';
  static const String normalPinKey = 'normal_pin';
  static const String duressPinKey = 'duress_pin';
  static const String inviteCodeKey = 'invite_code';
  
  // User data keys
  static const String idKey = 'id';
  static const String avatarKey = 'avatar';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Private constructor to prevent instantiation
  ApiConstants._();
} 