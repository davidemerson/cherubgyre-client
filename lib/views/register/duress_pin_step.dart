import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';

class DuressPinStep extends StatefulWidget {
  const DuressPinStep({super.key});

  @override
  _DuressPinStepState createState() => _DuressPinStepState();
}

class _DuressPinStepState extends State<DuressPinStep> {
  final _duressPinController = TextEditingController();
  final _confirmDuressPinController = TextEditingController();
  final _duressPinFocusNode = FocusNode();
  final _confirmDuressPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _duressPinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _duressPinController.dispose();
    _confirmDuressPinController.dispose();
    _duressPinFocusNode.dispose();
    _confirmDuressPinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Text(
              'Set Duress PIN',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Create a different 6-character PIN (letters and numbers) for emergency situations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            PinInput(
              label: 'Duress PIN',
              controller: _duressPinController,
              focusNode: _duressPinFocusNode,
              onChanged: (pin) {
                // PIN is not stored in view model anymore
                // Only validate format in real-time
              },
              onSubmitted: (_) {
                _confirmDuressPinFocusNode.requestFocus();
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            PinInput(
              label: 'Confirm Duress PIN',
              controller: _confirmDuressPinController,
              focusNode: _confirmDuressPinFocusNode,
              onChanged: (pin) {
                // PIN is not stored in view model anymore
                // Only validate format in real-time
              },
              onSubmitted: (_) {
                _handleNext();
              },
            ),
            SizedBox(height: screenHeight * 0.04),
            
            // Privacy Policy checkbox
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
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
                        Text(
                          'I agree to the',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Show privacy policy
                              },
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(' and ', style: TextStyle(fontSize: screenWidth * 0.035)),
                            GestureDetector(
                              onTap: () {
                                // TODO: Show terms
                              },
                              child: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
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
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _handleNext,
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
                    : Text(
                        'Complete Registration',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextButton(
              onPressed: () {
                context.read<RegisterViewModel>().prevStep();
              },
              child: const Text('Back'),
            ),
          ],
        );
      },
    );
  }

  void _handleNext() async {
    final viewModel = context.read<RegisterViewModel>();
    final duressPin = _duressPinController.text;
    final confirmPin = _confirmDuressPinController.text;
    
    // Validate duress PIN (compare against the stored normal PIN)
    final duressError = viewModel.validateDuressPin(duressPin, confirmPin, viewModel.normalPin ?? '');
    
    if (duressError != null) {
      viewModel.setError(duressError);
      return;
    }

    // Validate privacy policy
    final privacyError = viewModel.validatePrivacyPolicy();
    if (privacyError != null) {
      viewModel.setError(privacyError);
      return;
    }

    viewModel.setError(null);
    viewModel.setDuressPin(duressPin);
    
    // Perform registration
    final success = await viewModel.register();
    
    if (success && mounted) {
      // Navigate to success step
      viewModel.nextStep();
    }
  }
} 