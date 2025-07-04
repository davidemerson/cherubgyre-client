import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../view_models/auth_view_model.dart';

/// Final registration step - shows privacy policy and completes registration
class RegistrationSuccessStep extends StatelessWidget {
  const RegistrationSuccessStep({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Icon(
              Icons.check_circle,
              size: screenWidth * 0.2,
              color: Colors.green,
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            Text(
              'Almost Done!',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            Text(
              'Please review and accept our terms to complete registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Privacy Policy checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: viewModel.acceptedPrivacyPolicy,
                    onChanged: (value) {
                      viewModel.setPrivacyPolicyAccepted(value ?? false);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'I agree to the',
                          style: TextStyle(fontSize: 14),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Show privacy policy
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(' and ', style: TextStyle(fontSize: 14)),
                            GestureDetector(
                              onTap: () {
                                // TODO: Show terms
                              },
                              child: const Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Complete button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleComplete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Complete Registration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            // Show success info after registration
            if (viewModel.userData != null) ...[
              SizedBox(height: screenHeight * 0.04),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Registration Successful!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your username: ${viewModel.assignedUsername ?? ""}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _handleComplete(BuildContext context) async {
    final viewModel = context.read<RegisterViewModel>();
    
    // Validate privacy policy
    final error = viewModel.validatePrivacyPolicy();
    if (error != null) {
      viewModel.setError(error);
      return;
    }

    // Note: In a real app, you would collect PINs here or pass them securely
    // For this demo, we'll use placeholder values
    // In production, implement a secure way to pass PINs between steps
    
    final success = await viewModel.register('1234', '5678');
    
    if (success && context.mounted) {
      // Update auth state
      context.read<AuthViewModel>().setAuthenticated(true);
      
      // Show success briefly then navigate
      await Future.delayed(const Duration(seconds: 2));
      
      if (context.mounted) {
        // Pop back to login/main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
} 