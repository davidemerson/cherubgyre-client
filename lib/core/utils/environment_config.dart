import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure environment configuration utility
class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();

  static const _storage = FlutterSecureStorage();
  static String? _cachedServerUrl;

  /// Initialize environment configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: Could not load .env file: $e');
    }
  }

  /// Get API base URL with fallback
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://cherubgyre-dev-53de84d03c61.herokuapp.com';
  }

  /// Get the currently selected server URL (public or private)
  static Future<String> get selectedServerUrl async {
    if (_cachedServerUrl != null) {
      return _cachedServerUrl!;
    }

    try {
      final savedUrl = await _storage.read(key: 'selected_server_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _cachedServerUrl = savedUrl;
        return savedUrl;
      }
    } catch (e) {
      debugPrint('Error reading saved server URL: $e');
    }

    // Fallback to default public server
    _cachedServerUrl = apiBaseUrl;
    return _cachedServerUrl!;
  }

  /// Clear cached server URL (call when server selection changes)
  static void clearCachedServerUrl() {
    _cachedServerUrl = null;
  }

  /// Get environment name
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'production';
  }

  /// Check if running in debug mode
  static bool get isDebug {
    return kDebugMode;
  }

  /// Check if running in production
  static bool get isProduction {
    return environment.toLowerCase() == 'production';
  }

  /// Check if running in development
  static bool get isDevelopment {
    return environment.toLowerCase() == 'development';
  }

  /// Get app version
  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  /// Get build number
  static String get buildNumber {
    return dotenv.env['BUILD_NUMBER'] ?? '1';
  }

  /// Get API timeout in seconds
  static int get apiTimeoutSeconds {
    final timeout = dotenv.env['API_TIMEOUT_SECONDS'];
    return timeout != null ? int.tryParse(timeout) ?? 30 : 30;
  }

  /// Get maximum PIN length
  static int get maxPinLength {
    final maxLength = dotenv.env['MAX_PIN_LENGTH'];
    return maxLength != null ? int.tryParse(maxLength) ?? 6 : 6;
  }

  /// Get minimum PIN length
  static int get minPinLength {
    final minLength = dotenv.env['MIN_PIN_LENGTH'];
    return minLength != null ? int.tryParse(minLength) ?? 4 : 4;
  }

  /// Get session timeout in days
  static int get sessionTimeoutDays {
    final timeout = dotenv.env['SESSION_TIMEOUT_DAYS'];
    return timeout != null ? int.tryParse(timeout) ?? 30 : 30;
  }

  /// Get whether to enable debug logging
  static bool get enableDebugLogging {
    if (isProduction) return false;
    final enable = dotenv.env['ENABLE_DEBUG_LOGGING'];
    return enable?.toLowerCase() == 'true';
  }

  /// Get whether to enable crash reporting
  static bool get enableCrashReporting {
    final enable = dotenv.env['ENABLE_CRASH_REPORTING'];
    return enable?.toLowerCase() == 'true' ?? isProduction;
  }

  /// Get whether to enable analytics
  static bool get enableAnalytics {
    final enable = dotenv.env['ENABLE_ANALYTICS'];
    return enable?.toLowerCase() == 'true' ?? isProduction;
  }

  /// Validate environment configuration
  static bool validate() {
    final requiredVars = [
      'API_BASE_URL',
      'ENVIRONMENT',
    ];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null) {
        debugPrint('Warning: Missing required environment variable: $varName');
        return false;
      }
    }

    return true;
  }

  /// Get all environment variables (for debugging only)
  static Map<String, String> getAll() {
    if (!isDebug) {
      return {};
    }
    return dotenv.env;
  }
} 