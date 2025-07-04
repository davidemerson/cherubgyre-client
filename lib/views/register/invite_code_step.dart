import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../view_models/register_view_model.dart';

class InviteCodeStep extends StatelessWidget {
  const InviteCodeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(mediaQueryWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Invite Code',
            style: TextStyle(
              fontSize: mediaQueryWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          Text(
            'Please enter the invite code you received to create your account.',
            style: TextStyle(
              fontSize: mediaQueryWidth * 0.045,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.04),
          TextField(
            onChanged: viewModel.setInviteCode,
            inputFormatters: [
              // Allow any characters - let server validate
              LengthLimitingTextInputFormatter(100), // Generous limit for any format
            ],
            decoration: InputDecoration(
              errorText: viewModel.error,
              hintText: 'Enter your invite code',
              helperText: 'Enter the invite code you received',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: mediaQueryWidth * 0.04,
                vertical: mediaQueryHeight * 0.02,
              ),
            ),
            style: TextStyle(
              fontSize: mediaQueryWidth * 0.045,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: mediaQueryHeight * 0.04),
          SizedBox(
            width: double.infinity,
            height: mediaQueryHeight * 0.06,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      if (await viewModel.verifyInviteCode()) {
                        if (context.mounted) {
                          Provider.of<RegisterViewModel>(context, listen: false).nextStep();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                ),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      width: mediaQueryWidth * 0.05,
                      height: mediaQueryWidth * 0.05,
                      child: const CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: mediaQueryWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

 