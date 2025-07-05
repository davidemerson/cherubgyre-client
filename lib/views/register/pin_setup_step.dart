import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../widgets/pin_input.dart';

/// PIN setup step for registration
/// Uses StatefulWidget only for TextEditingController lifecycle management
class PinSetupStep extends StatefulWidget {
  const PinSetupStep({super.key});

  @override
  State<PinSetupStep> createState() => _PinSetupStepState();
}

class _PinSetupStepState extends State<PinSetupStep> {
  final _normalPinController = TextEditingController();
  final _confirmNormalPinController = TextEditingController();
  final _normalPinFocusNode = FocusNode();
  final _confirmNormalPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus first PIN field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _normalPinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    _normalPinController.dispose();
    _confirmNormalPinController.dispose();
    _normalPinFocusNode.dispose();
    _confirmNormalPinFocusNode.dispose();
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
              'Set Your PIN',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            Text(
              'Create a 6-character PIN using letters and numbers',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // PIN input
            PinInput(
              label: 'PIN',
              controller: _normalPinController,
              focusNode: _normalPinFocusNode,
              onSubmitted: (_) {
                _confirmNormalPinFocusNode.requestFocus();
              },
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Confirm PIN input
            PinInput(
              label: 'Confirm PIN',
              controller: _confirmNormalPinController,
              focusNode: _confirmNormalPinFocusNode,
              onSubmitted: (_) => _handleNext(),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Next button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Next',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            
            // Back button
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

  void _handleNext() {
    final viewModel = context.read<RegisterViewModel>();
    final normalPin = _normalPinController.text;
    final confirmPin = _confirmNormalPinController.text;
    
    // Validate PINs
    final error = viewModel.validateNormalPin(normalPin, confirmPin);
    if (error != null) {
      viewModel.setError(error);
      return;
    }
    
    // Clear error and proceed
    viewModel.setError(null);
    viewModel.setNormalPin(normalPin);
    viewModel.nextStep();
    
    // Note: PINs will be collected again in the final registration step
    // This is a simple approach that avoids complex state management
  }
} 