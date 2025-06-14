 import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Main Page',
          style: TextStyle(
            fontSize: textScaler.scale(size.width * 0.06),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              size: size.width * 0.06,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Center(
            child: Text(
              'Welcome to the Main Page!',
              style: TextStyle(
                fontSize: textScaler.scale(size.width * 0.05),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 