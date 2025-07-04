import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import 'invite_code_step.dart';
import 'pin_setup_step.dart';
import 'duress_pin_step.dart';
import 'registration_success_step.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local RegisterViewModel - disposed when widget is removed
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterViewContent(),
    );
  }
}

class _RegisterViewContent extends StatelessWidget {
  const _RegisterViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Consumer<RegisterViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (viewModel.step + 1) / 4,
                  backgroundColor: Colors.grey[300],
                ),
                
                // Step content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildCurrentStep(viewModel),
                  ),
                ),
                
                // Error message
                if (viewModel.error != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep(RegisterViewModel viewModel) {
    switch (viewModel.step) {
      case 0:
        return const InviteCodeStep();
      case 1:
        return const PinSetupStep();
      case 2:
        return const DuressPinStep();
      case 3:
        return const RegistrationSuccessStep();
      default:
        return const InviteCodeStep();
    }
  }
} 