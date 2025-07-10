import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_colors.dart';
import '../view_models/main_page_view_model.dart';
import 'login_view.dart';
import 'server_selection_view.dart';
// Feature imports will be added as we create them
// import '../features/broadcast/presentation/views/broadcast_feed_view.dart';
// import '../features/follow/presentation/views/follow_management_view.dart';
// import '../features/invite/presentation/views/invite_generation_view.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainPageViewModel(),
      child: const _MainPageContent(),
    );
  }
}

class _MainPageContent extends StatefulWidget {
  const _MainPageContent();

  @override
  State<_MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<_MainPageContent> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _PlaceholderTab(title: 'Broadcasts', icon: Icons.broadcast_on_personal),
    const _PlaceholderTab(title: 'Network', icon: Icons.people),
    const _PlaceholderTab(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Consumer<MainPageViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: mediaQueryWidth * 0.03,
              unselectedFontSize: mediaQueryWidth * 0.03,
              iconSize: mediaQueryWidth * 0.06,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.broadcast_on_personal),
                  label: 'Broadcasts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Network',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          floatingActionButton: _buildDuressButton(context, mediaQueryWidth),
        );
      },
    );
  }

  Widget _buildDuressButton(BuildContext context, double screenWidth) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to duress PIN entry
        _showDuressConfirmation(context);
      },
      backgroundColor: AppColors.duressRed,
      child: Icon(
        Icons.emergency,
        size: screenWidth * 0.07,
        color: Colors.white,
      ),
    );
  }

  void _showDuressConfirmation(BuildContext context) {
    // This will be replaced with navigation to duress PIN entry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duress broadcast feature coming soon'),
        backgroundColor: AppColors.duressRed,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Consumer<MainPageViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                title: Text(
                  'CherubGyre',
                  style: TextStyle(
                    fontSize: mediaQueryWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showSettings(context),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),

              // User Profile Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(mediaQueryWidth * 0.05),
                  child: _buildUserProfileCard(context, viewModel, mediaQueryWidth, mediaQueryHeight),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Quick Action Cards
              SliverPadding(
                padding: EdgeInsets.all(mediaQueryWidth * 0.05),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: mediaQueryWidth * 0.04,
                    mainAxisSpacing: mediaQueryWidth * 0.04,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildActionCard(
                      context,
                      icon: Icons.qr_code,
                      title: 'Generate Invite',
                      color: AppColors.primary,
                      onTap: () {
                        // TODO: Navigate to invite generation
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.person_search,
                      title: 'Find Users',
                      color: Colors.blue,
                      onTap: () {
                        // TODO: Navigate to user search
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.person_add,
                      title: 'Follow Requests',
                      color: Colors.green,
                      onTap: () {
                        // TODO: Navigate to follow requests
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.broadcast_on_home,
                      title: 'Active Broadcasts',
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to broadcasts
                      },
                    ),
                  ]),
                ),
              ),

              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Activity List (placeholder for now)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildActivityItem(context, mediaQueryWidth);
                  },
                  childCount: 5,
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: mediaQueryHeight * 0.1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserProfileCard(BuildContext context, MainPageViewModel viewModel, double width, double height) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: width * 0.15,
            height: width * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: viewModel.avatar != null && viewModel.avatar!.isNotEmpty
                ? _buildAvatarWidget(viewModel.avatar!, width * 0.15)
                : Icon(
                    Icons.person,
                    size: width * 0.08,
                    color: Colors.grey[600],
                  ),
          ),
          SizedBox(width: width * 0.04),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  viewModel.username ?? 'User',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Status Indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: height * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: width * 0.02,
                  height: width * 0.02,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: width * 0.02),
                Text(
                  'Safe',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: width * 0.08,
              color: color,
            ),
            SizedBox(height: width * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, double width) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: width * 0.02,
      ),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.1,
            height: width * 0.1,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications,
              size: width * 0.05,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New follow request',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '2 minutes ago',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSvgUrl(String url) {
    return url.toLowerCase().contains('.svg') || url.contains('svg');
  }

  Widget _buildAvatarWidget(String avatarUrl, double size) {
    if (_isSvgUrl(avatarUrl)) {
      return SvgPicture.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
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

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: width * 0.15,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: width * 0.04),
          Text(
            '$title Coming Soon',
            style: TextStyle(
              fontSize: width * 0.05,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the existing _SettingsSheet class as is
class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  bool _isSvgUrl(String url) {
    return url.toLowerCase().contains('.svg') || url.contains('svg');
  }

  Widget _buildAvatarWidget(String avatarUrl, double size) {
    if (_isSvgUrl(avatarUrl)) {
      return SvgPicture.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey[600],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Consumer<MainPageViewModel>(
      builder: (context, viewModel, child) {
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
              
              // Profile Section
              if (viewModel.username != null || viewModel.avatar != null) ...[
                Container(
                  padding: EdgeInsets.all(mediaQueryWidth * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      if (viewModel.avatar != null && viewModel.avatar!.isNotEmpty)
                        Container(
                          width: mediaQueryWidth * 0.1,
                          height: mediaQueryWidth * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: _buildAvatarWidget(viewModel.avatar!, mediaQueryWidth * 0.1),
                        )
                      else
                        Container(
                          width: mediaQueryWidth * 0.1,
                          height: mediaQueryWidth * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: mediaQueryWidth * 0.05,
                            color: Colors.grey[600],
                          ),
                        ),
                      
                      SizedBox(width: mediaQueryWidth * 0.03),
                      
                      // Username
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.username ?? 'User',
                              style: TextStyle(
                                fontSize: mediaQueryWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Account',
                              style: TextStyle(
                                fontSize: mediaQueryWidth * 0.035,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: mediaQueryHeight * 0.02),
              ],
              
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
      },
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