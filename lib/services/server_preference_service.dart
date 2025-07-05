import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerPreferenceService {
  static const _storage = FlutterSecureStorage();
  
  /// Check if user has already made a server selection choice
  static Future<bool> hasUserSelectedServer() async {
    try {
      final savedUrl = await _storage.read(key: 'selected_server_url');
      final savedType = await _storage.read(key: 'server_type');
      
      debugPrint('🔍 ServerPreferenceService: savedUrl = "$savedUrl", savedType = "$savedType"');
      
      // User has made a choice if either URL or type is saved
      final hasSelected = (savedUrl != null && savedUrl.isNotEmpty) || 
                         (savedType != null && savedType.isNotEmpty);
      
      debugPrint('🔍 ServerPreferenceService: hasUserSelectedServer = $hasSelected');
      return hasSelected;
    } catch (e) {
      debugPrint('Error checking server selection: $e');
      return false;
    }
  }

  /// Clear server selection (useful for testing or reset)
  static Future<void> clearServerSelection() async {
    try {
      await _storage.delete(key: 'selected_server_url');
      await _storage.delete(key: 'server_type');
    } catch (e) {
      debugPrint('Error clearing server selection: $e');
    }
  }
} 