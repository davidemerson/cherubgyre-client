import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/session_manager.dart';

/// Secure API client with proper authentication and error handling
class SecureApiClient {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Private constructor to prevent instantiation
  SecureApiClient._();

  /// Make an authenticated API request
  static Future<Map<String, dynamic>> authenticatedRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      // Get authentication token
      final token = await SessionManager.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      // Make request
      final response = await _makeRequest(
        endpoint: endpoint,
        method: method,
        body: body,
        headers: requestHeaders,
      );

      return response;
    } catch (e) {
      debugPrint('Authenticated request failed: $e');
      rethrow;
    }
  }

  /// Make a public API request (no authentication required)
  static Future<Map<String, dynamic>> publicRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Make request
      final response = await _makeRequest(
        endpoint: endpoint,
        method: method,
        body: body,
        headers: requestHeaders,
      );

      return response;
    } catch (e) {
      debugPrint('Public request failed: $e');
      rethrow;
    }
  }

  /// Internal method to make HTTP requests
  static Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers).timeout(_timeout);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(_timeout);
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(_timeout);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers).timeout(_timeout);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Parse response
    final responseBody = _parseResponse(response);
    
    // Handle authentication errors
    if (response.statusCode == 401) {
      await SessionManager.clearSession();
      throw Exception('Authentication failed. Please log in again.');
    }
    
    // Handle other HTTP errors
    if (response.statusCode >= 400) {
      throw Exception(responseBody['message'] ?? 'Request failed with status ${response.statusCode}');
    }

    return responseBody;
  }

  /// Parse HTTP response
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return {};
      }
      
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } catch (e) {
      debugPrint('Error parsing response: $e');
      return {
        'success': false,
        'message': 'Invalid response format',
      };
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await SessionManager.isAuthenticated();
  }

  /// Logout and clear session
  static Future<void> logout() async {
    await SessionManager.clearSession();
  }
} 