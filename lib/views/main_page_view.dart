import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'normalPin');
    await storage.delete(key: 'duressPin');

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cherubgyre',
          style: TextStyle(
            fontSize: textScaler.scale(mediaQueryWidth * 0.06),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              size: mediaQueryWidth * 0.06,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mediaQueryWidth * 0.05,
            vertical: mediaQueryHeight * 0.02,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  size: mediaQueryWidth * 0.2,
                  color: Colors.deepPurple,
                ),
                SizedBox(height: mediaQueryHeight * 0.04),
                Text(
                  'Welcome to Cherubgyre!',
                  style: TextStyle(
                    fontSize: textScaler.scale(mediaQueryWidth * 0.06),
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: mediaQueryHeight * 0.02),
                Text(
                  'You are now logged in successfully.',
                  style: TextStyle(
                    fontSize: textScaler.scale(mediaQueryWidth * 0.045),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 