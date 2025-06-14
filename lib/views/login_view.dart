import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main_page_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _simulateLogin(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'accessToken', value: 'dummy_token');

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPageView()),
      );
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: textScaler.scale(size.width * 0.06),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () => _simulateLogin(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                    ),
                    child: Text(
                      'Simulate Login',
                      style: TextStyle(
                        fontSize: textScaler.scale(size.width * 0.045),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextButton(
                  onPressed: () => _navigateToRegister(context),
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(
                      fontSize: textScaler.scale(size.width * 0.04),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 