import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/pin_input.dart';
import 'register/register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Local LoginViewModel - disposed when widget is removed
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginViewContent(),
    );
  }
}

class _LoginViewContent extends StatefulWidget {
  const _LoginViewContent();

  @override
  State<_LoginViewContent> createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<_LoginViewContent> {
  final GlobalKey<_PinFieldState> _pinFieldKey = GlobalKey<_PinFieldState>();

  Future<void> _handleLogin() async {
    debugPrint('🎯 _handleLogin() called from _LoginViewContentState');
    
    final pinFieldState = _pinFieldKey.currentState;
    if (pinFieldState == null) {
      debugPrint('❌ PIN field state is null!');
      return;
    }

    final viewModel = context.read<LoginViewModel>();
    final authState = context.read<AuthViewModel>();
    
    final pin = pinFieldState.pinValue;
    debugPrint('📝 PIN from field: ${pin.length} characters');
    
    debugPrint('🔄 Calling viewModel.login()...');
    final success = await viewModel.login(pin);
    debugPrint('🔄 viewModel.login() returned: $success');
    
    if (success && mounted) {
      debugPrint('✅ Login successful, showing success snackbar');
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Update global auth state
      authState.setAuthenticated(true);
      
      // Clear the PIN controller
      pinFieldState.controller.clear();
      debugPrint('✅ Auth state updated, PIN controller cleared');
    } else if (mounted && viewModel.error != null) {
      debugPrint('❌ Login failed, showing error snackbar: ${viewModel.error}');
      // Show error message as snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else {
      debugPrint('⚠️ Login failed but no error message available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = screenWidth * 0.05;

    return Scaffold(
      body: SafeArea(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isInitializing) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  
                  // Logo/Title
                  Text(
                    'CherubGyre',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: screenHeight * 0.05),
                  
                  // Welcome message
                  Text(
                    viewModel.isReturningUser 
                        ? 'Welcome back, ${viewModel.username}!'
                        : 'Login to your account',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: screenHeight * 0.05),
                  
                  // Username field (only if not returning user)
                  if (!viewModel.isReturningUser) ...[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: viewModel.setUsername,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                  
                  // PIN field
                  _PinField(
                    key: _pinFieldKey,
                    onLoginPressed: _handleLogin,
                  ),
                  
                  // Error message
                  if (viewModel.error != null) ...[
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.all(padding * 0.5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        viewModel.error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: screenWidth * 0.035,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Login button
                  _LoginButton(onPressed: _handleLogin),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Switch user / Register
                  if (viewModel.isReturningUser) ...[
                    TextButton(
                      onPressed: viewModel.clearSavedUser,
                      child: const Text('Not you? Switch user'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterView(),
                          ),
                        );
                      },
                      child: const Text('New user? Register here'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Simple PIN input field with local state
class _PinField extends StatefulWidget {
  final Future<void> Function() onLoginPressed;
  
  const _PinField({super.key, required this.onLoginPressed});

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus PIN field for returning users
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

  TextEditingController get controller => _controller;

  String get pinValue => _controller.text;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return PinInput(
          label: 'PIN',
          controller: _controller,
          focusNode: _focusNode,
          isVisible: viewModel.isPinVisible,
          onToggleVisibility: viewModel.togglePinVisibility,
          onSubmitted: (_) => widget.onLoginPressed(),
        );
      },
    );
  }
}

// Simple login button
class _LoginButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: screenHeight * 0.06,
          child: ElevatedButton(
            onPressed: viewModel.isLoading 
                ? null 
                : () async {
                    debugPrint('🔘 Login button pressed!');
                    debugPrint('📊 Current state - isLoading: ${viewModel.isLoading}, error: ${viewModel.error}');
                    await onPressed();
                  },
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
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }
} 