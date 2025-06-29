import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';
import '../../views/main_page_view.dart';
import 'invite_code_step.dart';
import 'pin_setup_step.dart';
import 'duress_pin_step.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  void _navigateToMain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPageView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Register',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.06),
            ),
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Consumer<RegisterViewModel>(
            builder: (context, viewModel, _) {
              // Handle successful registration
              if (viewModel.userData != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToMain(context);
                });
              }

              return Column(
                children: [
                  // Progress indicator
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(mediaQueryWidth * 0.04),
                    child: Row(
                      children: [
                        for (int i = 0; i < 3; i++)
                          Expanded(
                            child: Container(
                              height: mediaQueryHeight * 0.01,
                              margin: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.01),
                              decoration: BoxDecoration(
                                color: i <= viewModel.step 
                                    ? Colors.deepPurple 
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(mediaQueryHeight * 0.005),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Step content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(mediaQueryWidth * 0.05),
                      child: Column(
                        children: [
                          if (viewModel.step == 0)
                            const InviteCodeStep()
                          else if (viewModel.step == 1)
                            const PinSetupStep()
                          else if (viewModel.step == 2)
                            const DuressPinStep(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 