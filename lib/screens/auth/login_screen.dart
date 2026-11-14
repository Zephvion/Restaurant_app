
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/google_auth_service.dart';
import '../../core/services/push_notification_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/google_account_picker_sheet.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = GoogleAuthService.instance;

    if (!auth.isFirebaseReady) {
      _showMessage('Firebase is not configured yet.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await auth.signInWithEmailAndPassword(
        email: _identifier.text.trim(),
        password: _password.text,
      );

      try {
        await PushNotificationService.initialize();
      } catch (error) {
        debugPrint('FCM registration pending configuration: $error');
      }

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'user-not-found' => 'No account found for this email.',
        'wrong-password' || 'invalid-credential' =>
          'Invalid email or password.',
        'invalid-email' => 'Please enter a valid email.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'network-request-failed' => 'Check your internet connection.',
        _ => e.message ?? 'Login failed. Please try again.',
      };

      _showMessage(message);
    } catch (error) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
      debugPrint('Login error: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithGoogle() {
    if (!GoogleAuthService.instance.isFirebaseReady) {
      _showMessage('Firebase is not configured yet.');
      return;
    }

    showGoogleAccountPickerSheet(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: h * 0.10),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please login to your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: h * 0.09),
                AppTextField(
                  hint: 'Email',
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Password',
                  controller: _password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: h * 0.22),
                PrimaryButton(
                  label: _isLoading ? 'Logging in...' : 'Login',
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 20),
                GoogleSignInButton(
                  label: 'Login with google',
                  onPressed: _isLoading ? () {} : _loginWithGoogle,
                ),
                SizedBox(height: h * 0.05),
                _SignUpPrompt(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.signup),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Sign Up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
