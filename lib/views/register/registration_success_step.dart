import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../view_models/register_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../main_page_view.dart';
import '../login_view.dart';

/// Final registration step - shows registration success with username and avatar
class RegistrationSuccessStep extends StatelessWidget {
  const RegistrationSuccessStep({super.key});

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Success Icon
            Icon(
              Icons.check_circle,
              size: screenWidth * 0.2,
              color: Colors.green,
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Success Title
            Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Success Message
            Text(
              'Your account has been created successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // User Info Card
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Avatar and Username Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      if (viewModel.assignedAvatar != null && viewModel.assignedAvatar!.isNotEmpty)
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: _buildAvatarWidget(viewModel.assignedAvatar!, screenWidth * 0.2),
                        )
                      else
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: screenWidth * 0.1,
                            color: Colors.grey[600],
                          ),
                        ),
                      
                      SizedBox(width: screenWidth * 0.04),
                      
                      // Username Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Username:',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                viewModel.assignedUsername ?? "Unknown",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Important Message
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Text(
                            'Please save your username! You will need it to log in to your account.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.05),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login,
                      color: Colors.white,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Login to Your Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Additional Info
            Text(
              'You can now use your username and PIN to log in anytime',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[500],
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogin(BuildContext context) {
    // Navigate to login view and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }
} 