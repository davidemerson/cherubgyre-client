import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';
import '../main_page_view.dart';

class DuressPinStep extends StatelessWidget {
  const DuressPinStep({super.key});

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
            'Set your duress PIN',
            style: TextStyle(
              fontSize: textScaler.scale(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'This PIN will be used to trigger an emergency alert to your network.',
            style: TextStyle(
              fontSize: textScaler.scale(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.04),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.duressPin,
            builder: (context, pin, _) => PinInput(
              label: 'Duress PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setDuressPin,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.confirmDuressPin,
            builder: (context, confirmPin, _) => PinInput(
              label: 'Confirm Duress PIN',
              error: null,
              onChanged: Provider.of<RegisterViewModel>(context, listen: false).setConfirmDuressPin,
            ),
          ),
          SizedBox(height: size.height * 0.04),
          Selector<RegisterViewModel, String?>(
            selector: (_, vm) => vm.validateDuressPin(),
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
                  : () async {
                      final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                      final error = viewModel.validateDuressPin();
                      if (error == null) {
                        if (await viewModel.register()) {
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainPageView()),
                              (route) => false,
                            );
                          }
                        }
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