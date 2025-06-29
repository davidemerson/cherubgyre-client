import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';

class DuressPinStep extends StatelessWidget {
  const DuressPinStep({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;
    
    return Padding(
      padding: EdgeInsets.all(mediaQueryWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set Your Duress PIN',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.06),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          Text(
            'This PIN will be used to trigger an emergency alert to your network. It must be different from your normal PIN.',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.04),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.04),
          
          // Duress PIN Input
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.duressPin,
            builder: (context, pin, _) => PinInput(
              label: 'Duress PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setDuressPin,
            ),
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          
          // Confirm Duress PIN Input
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.confirmDuressPin,
            builder: (context, confirmPin, _) => PinInput(
              label: 'Confirm Duress PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setConfirmDuressPin,
            ),
          ),
          
          // Error Message
          SizedBox(height: mediaQueryHeight * 0.02),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.validateDuressPin(),
            builder: (context, error, _) => error == null
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(mediaQueryWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                      ),
                    ),
                  ),
          ),
          
          SizedBox(height: mediaQueryHeight * 0.04),
          
          // Privacy Policy and Terms Checkbox
          Container(
            padding: EdgeInsets.all(mediaQueryWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Selector<RegisterViewModel, bool>(
              selector: (_, vm) => vm.acceptedPrivacyPolicy,
              builder: (context, accepted, _) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: accepted,
                    onChanged: (value) {
                      Provider.of<RegisterViewModel>(context, listen: false)
                          .setPrivacyPolicyAccepted(value ?? false);
                    },
                    activeColor: Colors.deepPurple,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I agree to the',
                          style: TextStyle(
                            fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'You must accept these to continue with registration.',
                          style: TextStyle(
                            fontSize: textScaler.scale(mediaQueryWidth * 0.035),
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Privacy Policy Error
          SizedBox(height: mediaQueryHeight * 0.02),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.validatePrivacyPolicy(),
            builder: (context, error, _) => error == null
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(mediaQueryWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: textScaler.scale(mediaQueryWidth * 0.04),
                      ),
                    ),
                  ),
          ),
          
          SizedBox(height: mediaQueryHeight * 0.04),
          
          // Register Button
          Selector<RegisterViewModel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, _) => SizedBox(
              width: double.infinity,
              height: mediaQueryHeight * 0.06,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                        final error = viewModel.validateDuressPin();
                        final privacyError = viewModel.validatePrivacyPolicy();
                        if (error == null && privacyError == null) {
                          await viewModel.register();
                        } else {
                          // Trigger UI update by setting an error
                          viewModel.setError(error ?? privacyError);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: mediaQueryWidth * 0.05,
                        height: mediaQueryWidth * 0.05,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Complete Registration',
                        style: TextStyle(
                          fontSize: textScaler.scale(mediaQueryWidth * 0.05),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          
          SizedBox(height: mediaQueryHeight * 0.02),
          
          // Back Button
          TextButton(
            onPressed: () {
              Provider.of<RegisterViewModel>(context, listen: false).prevStep();
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
      ),
    );
  }
} 