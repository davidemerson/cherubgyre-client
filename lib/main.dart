import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/utils/environment_config.dart';
import 'services/api_client.dart';
import 'services/server_preference_service.dart';
import 'view_models/auth_view_model.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/main_page_view.dart';
import 'views/server_selection_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvironmentConfig.initialize();
  
  // Initialize API client
  await ApiClient.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CherubGyre',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppWrapper(),
    );
  }
}

/// App wrapper that handles server selection and authentication flow
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isCheckingServerPreference = true;
  bool _hasSelectedServer = false;

  @override
  void initState() {
    super.initState();
    _checkServerPreference();
  }

  Future<void> _checkServerPreference() async {
    // Record start time BEFORE any operations
    final startTime = DateTime.now();
    const minimumSplashDuration = Duration(milliseconds: 2500);
    
    if (kDebugMode) {
      debugPrint('🔍 Starting server preference check...');
    }
    
    // Force clear preferences for testing
    await ServerPreferenceService.clearServerSelection();
    if (kDebugMode) {
      debugPrint('🔍 Cleared server preferences for testing');
    }
    
    final hasSelected = await ServerPreferenceService.hasUserSelectedServer();
    if (kDebugMode) {
      debugPrint('🔍 Server preference result: hasSelected = $hasSelected');
    }
    
    // Calculate total elapsed time since method started
    final totalElapsedTime = DateTime.now().difference(startTime);
    if (kDebugMode) {
      debugPrint('🔍 Total elapsed time: ${totalElapsedTime.inMilliseconds}ms');
    }
    
    // Ensure splash screen stays visible for at least 2.5 seconds
    if (totalElapsedTime < minimumSplashDuration) {
      final remainingTime = minimumSplashDuration - totalElapsedTime;
      if (kDebugMode) {
        debugPrint('🔍 Waiting ${remainingTime.inMilliseconds}ms to complete minimum splash duration');
      }
      await Future.delayed(remainingTime);
    } else {
      if (kDebugMode) {
        debugPrint('🔍 Minimum splash duration already met (${totalElapsedTime.inMilliseconds}ms)');
      }
    }
    
    // Only update state after the full delay
    if (mounted) {
      setState(() {
        _hasSelectedServer = hasSelected;
        _isCheckingServerPreference = false;
      });
      if (kDebugMode) {
        debugPrint('🔍 AppWrapper state updated: _hasSelectedServer = $_hasSelectedServer, _isCheckingServerPreference = $_isCheckingServerPreference');
      }
      
      // Only start auth check after server preference is determined AND state is updated
      if (_hasSelectedServer) {
        if (kDebugMode) {
          debugPrint('🔍 Starting auth check after server preference...');
        }
        // Use a microtask to ensure state update is processed first
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          await authViewModel.checkAuthStatus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthViewModel>(context);
    if (kDebugMode) {
      debugPrint('🔍 AppWrapper build: _isCheckingServerPreference=$_isCheckingServerPreference, _hasSelectedServer=$_hasSelectedServer, authState.isCheckingAuth=${authState.isCheckingAuth}, authState.isAuthenticated=${authState.isAuthenticated}');
    }
    // Show splash only while checking server preference
    if (_isCheckingServerPreference) {
      if (kDebugMode) {
        debugPrint('🔍 Showing SplashView (checking server preference)');
      }
      return const SplashView();
    }

    // Show server selection first if user hasn't made a choice yet
    if (!_hasSelectedServer) {
      if (kDebugMode) {
        debugPrint('🔍 Showing ServerSelectionView (no server selected)');
      }
      return const ServerSelectionView();
    }

    // Show splash while checking auth (only after server is selected)
    if (authState.isCheckingAuth) {
      if (kDebugMode) {
        debugPrint('🔍 Showing SplashView (checking auth)');
      }
      return const SplashView();
    }

    // Show main app if authenticated
    if (authState.isAuthenticated) {
      if (kDebugMode) {
        debugPrint('🔍 Showing MainPageView (authenticated)');
      }
      return const MainPageView();
    }

    // Show login for returning users who have already selected a server
    if (kDebugMode) {
      debugPrint('🔍 Showing LoginView (not authenticated)');
    }
    return const LoginView();
  }
}
