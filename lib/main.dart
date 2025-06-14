import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'view_models/app_state.dart';
import 'views/splash_view.dart';
import 'views/register/register_view.dart';
import 'views/login_view.dart';
import 'views/main_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (create .env file with API_BASE_URL)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file doesn't exist, continue with defaults
    // Using debugPrint instead of print for production code
    debugPrint('Warning: .env file not found, using default values');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Cherubgyre',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashView(),
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/main': (context) => const MainPageView(),
        },
      ),
    );
  }
}
