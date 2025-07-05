import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/themes/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

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
            
            // Loading indicator
            SizedBox(
              width: mediaQueryWidth * 0.1,
              height: mediaQueryWidth * 0.1,
              child: const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 