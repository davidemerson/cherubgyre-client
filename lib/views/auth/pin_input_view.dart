import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../main_page_view.dart';
import '../duress/duress_alert_view.dart';

class PinInputView extends StatelessWidget {
  const PinInputView({super.key});

  void _navigateToMain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPageView()),
    );
  }

  void _navigateToDuressAlert(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DuressAlertView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
            child: Consumer<AuthViewModel>(
              builder: (context, viewModel, _) {
                // Handle navigation based on PIN type
                if (viewModel.pinType != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (viewModel.pinType == PinType.normal) {
                      _navigateToMain(context);
                    } else if (viewModel.pinType == PinType.duress) {
                      _navigateToDuressAlert(context);
                    }
                  });
                }

                return Column(
                  children: [
                    SizedBox(height: mediaQueryHeight * 0.1),
                    
                    // App Title
                    Text(
                      'Cherubgyre',
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.08),
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: mediaQueryHeight * 0.02),
                    Text(
                      'Enter Your PIN',
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.05),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: mediaQueryHeight * 0.06),
                    
                    // PIN Input Field
                    TextField(
                      onChanged: viewModel.setPin,
                      obscureText: !viewModel.isPinVisible,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Enter PIN',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.isPinVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: viewModel.togglePinVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: mediaQueryWidth * 0.04,
                          vertical: mediaQueryHeight * 0.02,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.06),
                        letterSpacing: 8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    
                    // Error Message
                    if (viewModel.error != null) ...[
                      SizedBox(height: mediaQueryHeight * 0.02),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(mediaQueryWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          viewModel.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: mediaQueryHeight * 0.04),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: mediaQueryHeight * 0.06,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                await viewModel.verifyPin();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? SizedBox(
                                width: mediaQueryWidth * 0.05,
                                height: mediaQueryWidth * 0.05,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: textScaler.scale(mediaQueryWidth * 0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Back to splash
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
} 