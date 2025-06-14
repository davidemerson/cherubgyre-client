import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import 'invite_code_step.dart';
import 'pin_setup_step.dart';
import 'duress_pin_step.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Consumer<RegisterViewModel>(
              builder: (context, viewModel, _) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    if (viewModel.step == 0)
                      const InviteCodeStep()
                    else if (viewModel.step == 1)
                      const PinSetupStep()
                    else if (viewModel.step == 2)
                      const DuressPinStep(),
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