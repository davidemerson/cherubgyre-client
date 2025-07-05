import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/environment_config.dart';
import '../services/server_validation_service.dart';
import '../services/api_client.dart';

enum ServerType { public, private }

class ServerSelectionViewModel extends ChangeNotifier {
  final ServerValidationService _validationService;
  final _storage = const FlutterSecureStorage();
  
  ServerType _selectedServerType = ServerType.public;
  String _privateServerUrl = '';
  bool _isLoading = false;
  String? _error;
  bool _isValidating = false;

  ServerSelectionViewModel() : _validationService = ServerValidationService() {
    // Load saved server config when view model is created
    _loadSavedServerConfig();
  }

  ServerType get selectedServerType => _selectedServerType;
  String get privateServerUrl => _privateServerUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isValidating => _isValidating;

  void setServerType(ServerType type) {
    if (_selectedServerType != type) {
      _selectedServerType = type;
      _error = null;
      notifyListeners();
    }
  }

  void setPrivateServerUrl(String url) {
    final trimmedUrl = url.trim();
    if (_privateServerUrl != trimmedUrl) {
      _privateServerUrl = trimmedUrl;
      _error = null;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  String? validatePrivateServerUrl() {
    if (_privateServerUrl.isEmpty) {
      return 'Server URL is required';
    }
    
    // Basic URL format validation
    final urlRegex = RegExp(
      r'^https?://[a-zA-Z0-9\-._~:/?#[\]@!$&()*+,;=%]+$',
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(_privateServerUrl)) {
      return 'Please enter a valid server URL';
    }
    
    // Ensure URL has proper scheme
    if (!_privateServerUrl.startsWith('http://') && !_privateServerUrl.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    
    // Prefer HTTPS for security
    if (_privateServerUrl.startsWith('http://') && !kDebugMode) {
      return 'HTTPS is required for security';
    }
    
    return null;
  }

  Future<bool> validateAndSaveServer() async {
    if (_selectedServerType == ServerType.public) {
      // Use default public server
      await _saveServerConfig(EnvironmentConfig.apiBaseUrl);
      // Reinitialize API client with new server
      await ApiClient.reinitializeWithNewServer();
      return true;
    }

    // Validate private server URL
    final validationError = validatePrivateServerUrl();
    if (validationError != null) {
      setError(validationError);
      return false;
    }

    // Test server connectivity using /health endpoint
    setLoading(true);
    _isValidating = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('🔍 Validating server: $_privateServerUrl');
      }
      
      final isValid = await _validationService.validateServer(_privateServerUrl);
      
      if (isValid) {
        if (kDebugMode) {
          debugPrint('✅ Server validation successful');
        }
        await _saveServerConfig(_privateServerUrl);
        // Reinitialize API client with new server
        await ApiClient.reinitializeWithNewServer();
        setError(null);
        return true;
      } else {
        setError('Server is not responding. Please check the URL and ensure the server is running.');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Server validation error: $e');
      }
      setError('Unable to connect to server. Please check your internet connection and try again.');
      return false;
    } finally {
      setLoading(false);
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<void> _saveServerConfig(String serverUrl) async {
    await _storage.write(key: 'selected_server_url', value: serverUrl);
    await _storage.write(key: 'server_type', value: _selectedServerType.name);
  }

  Future<void> _loadSavedServerConfig() async {
    try {
      final savedUrl = await _storage.read(key: 'selected_server_url');
      final savedType = await _storage.read(key: 'server_type');
      
      bool hasChanges = false;
      
      if (savedUrl != null && savedUrl.isNotEmpty && _privateServerUrl != savedUrl) {
        _privateServerUrl = savedUrl;
        hasChanges = true;
      }
      
      if (savedType != null) {
        final newType = ServerType.values.firstWhere(
          (type) => type.name == savedType,
          orElse: () => ServerType.public,
        );
        if (_selectedServerType != newType) {
          _selectedServerType = newType;
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved server config: $e');
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
} 