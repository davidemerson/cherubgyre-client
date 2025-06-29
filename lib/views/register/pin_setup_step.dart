import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';

class PinSetupStep extends StatelessWidget {
  const PinSetupStep({super.key});

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
            'Set Your PIN',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.06),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          Text(
            'This PIN will be used to unlock the app and access your account. Choose a secure 4-6 digit PIN.',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.04),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.04),
          
          // PIN Input
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.normalPin,
            builder: (context, pin, _) => PinInput(
              label: 'Enter PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setNormalPin,
            ),
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          
          // Confirm PIN Input
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.confirmNormalPin,
            builder: (context, confirmPin, _) => PinInput(
              label: 'Confirm PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setConfirmNormalPin,
            ),
          ),
          
          // Error Message
          SizedBox(height: mediaQueryHeight * 0.02),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.validateNormalPin(),
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
          
          // Next Button
          Selector<RegisterViewModel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, _) => SizedBox(
              width: double.infinity,
              height: mediaQueryHeight * 0.06,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                        final error = viewModel.validateNormalPin();
                        if (error == null) {
                          viewModel.nextStep();
                        } else {
                          viewModel.setError(error);
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
                        'Next',
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