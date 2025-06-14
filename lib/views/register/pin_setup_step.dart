import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';

class PinSetupStep extends StatelessWidget {
  const PinSetupStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set your PIN',
            style: TextStyle(
              fontSize: textScaler.scale(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'This PIN will be used to unlock the app and access your account.',
            style: TextStyle(
              fontSize: textScaler.scale(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.04),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.normalPin,
            builder: (context, pin, _) => PinInput(
              label: 'Enter PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setNormalPin,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.confirmNormalPin,
            builder: (context, confirmPin, _) => PinInput(
              label: 'Confirm PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setConfirmNormalPin,
            ),
          ),
          SizedBox(height: size.height * 0.04),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.validateNormalPin(),
            builder: (context, error, _) => error == null
                ? const SizedBox.shrink()
                : Text(error, style: const TextStyle(color: Colors.red)),
          ),
          SizedBox(height: size.height * 0.02),
          Selector<RegisterViewModel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, _) => ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                      final error = viewModel.validateNormalPin();
                      if (error == null) {
                        viewModel.nextStep();
                      } else {
                        viewModel.notifyListeners();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
} 