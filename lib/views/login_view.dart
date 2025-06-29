import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
import '../Utils/colors.dart';
import '../Utils/typography.dart';
import '../widgets/pin_input.dart';
import 'register/register_view.dart';
import 'main_page_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isInitializing) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Welcome message
                  Selector<LoginViewModel, bool>(
                    selector: (context, vm) => vm.isReturningUser,
                    builder: (context, isReturningUser, child) {
                      return Column(
                        children: [
                          Text(
                            isReturningUser 
                                ? 'Welcome back!'
                                : 'Welcome to CherubGyre',
                            style: AppTypography.headline1.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            isReturningUser
                                ? 'Enter your PIN to continue'
                                : 'Sign in to your account',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Username field (hidden for returning users)
                  Selector<LoginViewModel, bool>(
                    selector: (context, vm) => vm.isReturningUser,
                    builder: (context, isReturningUser, child) {
                      if (isReturningUser) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          _UsernameField(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  
                  // PIN field
                  _PinField(),
                  
                  const SizedBox(height: 32),
                  
                  // Error message
                  Selector<LoginViewModel, String?>(
                    selector: (context, vm) => vm.error,
                    builder: (context, error, child) {
                      if (error == null) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: AppTypography.body2.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  
                  // Login button
                  Selector<LoginViewModel, bool>(
                    selector: (context, vm) => vm.isLoading,
                    builder: (context, isLoading, child) {
                      return ElevatedButton(
                        onPressed: isLoading ? null : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.onPrimary,
                                ),
                              ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Clear saved user option (for returning users)
                  Selector<LoginViewModel, bool>(
                    selector: (context, vm) => vm.isReturningUser,
                    builder: (context, isReturningUser, child) {
                      if (!isReturningUser) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              context.read<LoginViewModel>().clearSavedUser();
                            },
                            child: Text(
                              'Sign in with different account',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login();
    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPageView(),
        ),
      );
    }
  }
}

class _UsernameField extends StatefulWidget {
  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LoginViewModel>();
      _controller.text = viewModel.username;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: viewModel.setUsername,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            // Focus will be handled by PIN field
          },
        );
      },
    );
  }
}

class _PinField extends StatefulWidget {
  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LoginViewModel>();
      if (viewModel.isReturningUser) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return PinInput(
          controller: _controller,
          focusNode: _focusNode,
          isVisible: viewModel.isPinVisible,
          onChanged: viewModel.setPin,
          onToggleVisibility: viewModel.togglePinVisibility,
          onSubmitted: (_) {
            final loginView = context.findAncestorWidgetOfExactType<LoginView>();
            if (loginView != null) {
              _handleLogin(context);
            }
          },
        );
      },
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login();
    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPageView(),
        ),
      );
    }
  }
} 