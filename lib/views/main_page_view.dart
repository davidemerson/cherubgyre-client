import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/themes/app_colors.dart';
import 'login_view.dart';
import 'server_selection_view.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'CherubGyre',
          style: TextStyle(
            fontSize: mediaQueryWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mediaQueryWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              Container(
                padding: EdgeInsets.all(mediaQueryWidth * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome to CherubGyre',
                      style: TextStyle(
                        fontSize: mediaQueryWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: mediaQueryHeight * 0.01),
                    Text(
                      'Your secure communication platform',
                      style: TextStyle(
                        fontSize: mediaQueryWidth * 0.045,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: mediaQueryHeight * 0.04),
              
              // Main features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: mediaQueryWidth * 0.04,
                  mainAxisSpacing: mediaQueryHeight * 0.02,
                  children: [
                    _FeatureCard(
                      icon: Icons.message,
                      title: 'Messages',
                      subtitle: 'Secure chat',
                      onTap: () {
                        // TODO: Navigate to messages
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.people,
                      title: 'Contacts',
                      subtitle: 'Manage network',
                      onTap: () {
                        // TODO: Navigate to contacts
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'Share location',
                      onTap: () {
                        // TODO: Navigate to location sharing
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap: () {
                        _showSettings(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SettingsSheet(),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(mediaQueryWidth * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: mediaQueryWidth * 0.1,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          
          Text(
            'Settings',
            style: TextStyle(
              fontSize: mediaQueryWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: mediaQueryHeight * 0.03),
          
          // Server Settings
          ListTile(
            leading: const Icon(Icons.dns, color: AppColors.primary),
            title: const Text('Server Settings'),
            subtitle: const Text('Change server configuration'),
            onTap: () {
              Navigator.pop(context);
              _showServerSettings(context);
            },
          ),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            onTap: () async {
              Navigator.pop(context);
              await _logout(context);
            },
          ),
          
          SizedBox(height: mediaQueryHeight * 0.02),
        ],
      ),
    );
  }

  void _showServerSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ServerSelectionView(),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(mediaQueryWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: mediaQueryWidth * 0.1,
                color: AppColors.primary,
              ),
              SizedBox(height: mediaQueryHeight * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: mediaQueryWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: mediaQueryHeight * 0.01),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: mediaQueryWidth * 0.035,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 