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
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Invite Code',
            style: TextStyle(
              fontSize: textScaler.scale(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'Please enter the alphanumeric invite code you received to create your account.',
            style: TextStyle(
              fontSize: textScaler.scale(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.04),
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
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
            ),
            style: TextStyle(
              fontSize: textScaler.scale(16),
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: size.height * 0.04),
          ElevatedButton(
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
              padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : const Text('Continue'),
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