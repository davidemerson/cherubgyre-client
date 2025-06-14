import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_view.dart';
import 'main_page_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const _delay = Duration(seconds: 2);
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Start timer to transition after splash delay
    Timer(_delay, _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    // Read token from secure storage
    final token = await _storage.read(key: 'accessToken');

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      // Navigate to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    } else {
      // Navigate to main page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/splash_logo.svg',
              width: size.width * 0.4,
              height: size.width * 0.4,
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Cherubgyre',
              style: TextStyle(
                fontSize: textScaler.scale(size.width * 0.08),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: size.width * 0.1,
              height: size.width * 0.1,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
} 