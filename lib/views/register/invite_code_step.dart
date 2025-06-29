import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../view_models/register_view_model.dart';

class InviteCodeStep extends StatelessWidget {
  const InviteCodeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();
    final textScaler = MediaQuery.of(context).textScaler;
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
              fontSize: textScaler.scale(mediaQueryWidth * 0.06),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.02),
          Text(
            'Please enter the alphanumeric invite code you received to create your account.',
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.04),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaQueryHeight * 0.04),
          TextField(
            onChanged: viewModel.setInviteCode,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(20),
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              errorText: viewModel.error,
              hintText: 'Enter invite code (e.g., ABC123XYZ)',
              helperText: 'Letters and numbers only, up to 20 characters',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: mediaQueryWidth * 0.04,
                vertical: mediaQueryHeight * 0.02,
              ),
            ),
            style: TextStyle(
              fontSize: textScaler.scale(mediaQueryWidth * 0.045),
              letterSpacing: 1.2,
              fontFamily: 'monospace',
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
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mediaQueryWidth * 0.02),
                ),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      width: mediaQueryWidth * 0.05,
                      height: mediaQueryWidth * 0.05,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: textScaler.scale(mediaQueryWidth * 0.05),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
} 