import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/environment_config.dart';
import 'view_models/auth_view_model.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/main_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvironmentConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'CherubGyre',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Simple auth wrapper that shows login or main app based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authState, _) {
        // Show splash while checking auth
        if (authState.isCheckingAuth) {
          return const SplashView();
        }

        // Show main app if authenticated, login otherwise
        return authState.isAuthenticated 
            ? const MainPageView() 
            : const LoginView();
      },
    );
  }
}
