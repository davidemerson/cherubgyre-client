import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/server_selection_view_model.dart';
import '../core/themes/app_colors.dart';
import '../services/server_preference_service.dart';
import 'login_view.dart';
import 'package:flutter/foundation.dart';

class ServerSelectionView extends StatelessWidget {
  const ServerSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local ServerSelectionViewModel - disposed when widget is removed
    return ChangeNotifierProvider(
      create: (_) => ServerSelectionViewModel(),
      child: const _ServerSelectionViewContent(),
    );
  }
}

class _ServerSelectionViewContent extends StatelessWidget {
  const _ServerSelectionViewContent();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🔍 ServerSelectionView: Building content');
    }
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Consumer<ServerSelectionViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: EdgeInsets.all(mediaQueryWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(height: mediaQueryHeight * 0.05),
                  Text(
                    'Choose Your Server',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: mediaQueryHeight * 0.02),
                  Text(
                    'Select how you want to connect to CherubGyre',
                    style: TextStyle(
                      fontSize: mediaQueryWidth * 0.04,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: mediaQueryHeight * 0.06),

                  // Server Options
                  _buildServerOption(
                    context,
                    viewModel,
                    ServerType.public,
                    'Public Server',
                    'Connect to the official CherubGyre server',
                    Icons.public,
                    mediaQueryWidth,
                    mediaQueryHeight,
                  ),
                  
                  SizedBox(height: mediaQueryHeight * 0.03),
                  
                  _buildServerOption(
                    context,
                    viewModel,
                    ServerType.private,
                    'Private Server',
                    'Connect to your own CherubGyre server',
                    Icons.security,
                    mediaQueryWidth,
                    mediaQueryHeight,
                  ),

                  // Private Server URL Input
                  if (viewModel.selectedServerType == ServerType.private) ...[
                    SizedBox(height: mediaQueryHeight * 0.04),
                    Text(
                      'Server URL',
                      style: TextStyle(
                        fontSize: mediaQueryWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: mediaQueryHeight * 0.02),
                    _PrivateServerUrlField(viewModel: viewModel),
                  ],

                  // Error Message
                  if (viewModel.error != null) ...[
                    SizedBox(height: mediaQueryHeight * 0.02),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: mediaQueryHeight * 0.06,
                            child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : () => _handleContinue(context, viewModel),
          style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Text(
                              viewModel.isValidating ? 'Testing /health endpoint...' : 'Continue',
                              style: TextStyle(
                                fontSize: mediaQueryWidth * 0.05,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimary,
                              ),
                            ),
                    ),
                  ),
                  
                  // Debug button to clear preferences (temporary)
                  SizedBox(height: mediaQueryHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: mediaQueryHeight * 0.05,
                    child: TextButton(
                      onPressed: () async {
                        await ServerPreferenceService.clearServerSelection();
                        if (kDebugMode) {
                          debugPrint('🔍 Cleared server preferences');
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const ServerSelectionView()),
                          );
                        }
                      },
                      child: const Text(
                        'Clear Preferences (Debug)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerOption(
    BuildContext context,
    ServerSelectionViewModel viewModel,
    ServerType serverType,
    String title,
    String subtitle,
    IconData icon,
    double width,
    double height,
  ) {
    final isSelected = viewModel.selectedServerType == serverType;
    
    return GestureDetector(
      onTap: () {
        viewModel.setServerType(serverType);
      },
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context, ServerSelectionViewModel viewModel) async {
    final success = await viewModel.validateAndSaveServer();
    
    if (success && context.mounted) {
      // Navigate to login view after server selection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }
}

// Separate widget for the private server URL field to handle TextEditingController lifecycle
class _PrivateServerUrlField extends StatefulWidget {
  final ServerSelectionViewModel viewModel;
  
  const _PrivateServerUrlField({required this.viewModel});

  @override
  State<_PrivateServerUrlField> createState() => _PrivateServerUrlFieldState();
}

class _PrivateServerUrlFieldState extends State<_PrivateServerUrlField> {
  final _urlController = TextEditingController();
  final _urlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set the URL controller text if there's a saved URL
      if (widget.viewModel.privateServerUrl.isNotEmpty) {
        _urlController.text = widget.viewModel.privateServerUrl;
      }
      // Focus the URL field when private server is selected
      if (widget.viewModel.selectedServerType == ServerType.private) {
        _urlFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _urlController,
      focusNode: _urlFocusNode,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onChanged: widget.viewModel.setPrivateServerUrl,
      onSubmitted: (_) async {
        final success = await widget.viewModel.validateAndSaveServer();
        if (success && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginView()),
          );
        }
      },
      decoration: InputDecoration(
        hintText: 'https://your-server.com',
        helperText: 'Server must have a /health endpoint',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
} 