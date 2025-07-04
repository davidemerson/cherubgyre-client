import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/themes/app_colors.dart';
import 'login_view.dart';
import 'register/register_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const _delay = Duration(seconds: 2);
  final _storage = const FlutterSecureStorage();
  bool _showAuthOptions = false;

  @override
  void initState() {
    super.initState();
    // Show splash for 2 seconds, then show auth options
    Timer(_delay, () {
      if (mounted) {
        setState(() {
          _showAuthOptions = true;
        });
      }
    });
  }

  Future<void> _checkExistingUser() async {
    final token = await _storage.read(key: 'accessToken');
    final hasUser = token != null && token.isNotEmpty;
    
    if (mounted) {
      if (hasUser) {
        // Existing user - navigate to login (which will auto-fill username)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      } else {
        // New user - stay on splash with Register button
        setState(() {
          _showAuthOptions = true;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterView()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/splash_logo.svg',
              width: mediaQueryWidth * 0.4,
              height: mediaQueryWidth * 0.4,
            ),
            SizedBox(height: mediaQueryHeight * 0.02),
            Text(
              'Cherubgyre',
              style: TextStyle(
                fontSize: mediaQueryWidth * 0.08,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: mediaQueryHeight * 0.04),
            
            if (!_showAuthOptions) ...[
              // Loading indicator during splash
              SizedBox(
                width: mediaQueryWidth * 0.1,
                height: mediaQueryWidth * 0.1,
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
              // Auth options after splash
              Text(
                'Welcome to Cherubgyre',
                style: TextStyle(
                  fontSize: mediaQueryWidth * 0.05,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: mediaQueryHeight * 0.06),
              
              // Register Button
              SizedBox(
                width: mediaQueryWidth * 0.8,
                height: mediaQueryHeight * 0.06,
                child: ElevatedButton(
                  onPressed: _navigateToRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              
              // Login Button
              SizedBox(
                width: mediaQueryWidth * 0.8,
                height: mediaQueryHeight * 0.06,
                child: OutlinedButton(
                  onPressed: _navigateToLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 