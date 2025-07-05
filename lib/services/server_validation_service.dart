import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ServerValidationService {
  static const Duration _timeout = Duration(seconds: 10);
  
  Future<bool> validateServer(String serverUrl) async {
    try {
      // Normalize URL
      final normalizedUrl = _normalizeUrl(serverUrl);
      
      // Create Dio instance with timeout
      final dio = Dio(BaseOptions(
        baseUrl: normalizedUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ));

      // Test connectivity using the /health endpoint
      // This is the primary endpoint for server validation
      try {
        final response = await dio.get('/health');
        
        // Accept any 2xx response as valid
        if (response.statusCode != null && 
            response.statusCode! >= 200 && 
            response.statusCode! < 300) {
          debugPrint('✅ Server validation successful: $normalizedUrl/health');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ /health endpoint failed: $e');
        
        // Fallback to other endpoints if /health doesn't work
        final fallbackEndpoints = [
          '/ping',
          '/api/health',
          '/v1/health',
          '/', // Root endpoint
        ];

        for (final endpoint in fallbackEndpoints) {
          try {
            final response = await dio.get(endpoint);
            
            // Accept any 2xx response as valid
            if (response.statusCode != null && 
                response.statusCode! >= 200 && 
                response.statusCode! < 300) {
              debugPrint('✅ Server validation successful (fallback): $normalizedUrl$endpoint');
              return true;
            }
          } catch (e) {
            // Continue to next endpoint if this one fails
            debugPrint('⚠️ Fallback endpoint $endpoint failed: $e');
            continue;
          }
        }
      }

      // If no health endpoints work, try a simple HEAD request to root
      try {
        final response = await dio.head('/');
        if (response.statusCode != null && 
            response.statusCode! >= 200 && 
            response.statusCode! < 500) {
          debugPrint('✅ Server validation successful (HEAD): $normalizedUrl');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ HEAD request failed: $e');
      }

      debugPrint('❌ Server validation failed: $normalizedUrl');
      return false;
      
    } catch (e) {
      debugPrint('❌ Server validation error: $e');
      return false;
    }
  }

  String _normalizeUrl(String url) {
    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    // Ensure URL has proper scheme
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    return url;
  }

  Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
} 