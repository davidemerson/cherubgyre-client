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
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            const Text(
              'Set Duress PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create a different 4-6 digit PIN for emergency situations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _handleNext,
                child: viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Next'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNext() {
    final viewModel = context.read<RegisterViewModel>();
    final duressPin = _duressPinController.text;
    final confirmPin = _confirmDuressPinController.text;
    // We need to get the normal PIN from the previous step
    // For now, we'll pass empty string and handle validation in the final step
    final duressError = viewModel.validateDuressPin(duressPin, confirmPin, '');
    
    if (duressError != null) {
      viewModel.setError(duressError);
      return;
    }

    viewModel.nextStep();
  }
} 