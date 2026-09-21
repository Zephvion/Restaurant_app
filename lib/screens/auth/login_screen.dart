import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/google_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/primary_button.dart';

/// "Welcome Back!" login screen connected to Firebase AuthService.
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

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.instance.signInWithEmail(
        email: _identifier.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        final name = user.displayName.isNotEmpty
            ? user.displayName
            : 'Welcome back';
        AppBanner.showSuccess(
          context,
          'Logged in successfully! $name.',
          title: 'Welcome Back',
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppBanner.showError(
          context,
          'Login failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final profile = await GoogleAuthService.instance.signInWithRealGoogle();
      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Signed in as ${profile.displayName} (${profile.email})!',
          title: 'Google Sign-In',
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString().replaceAll('Exception:', '').trim();
        AppBanner.showError(
          context,
          errText.isNotEmpty
              ? errText
              : 'Google Sign-In was cancelled or encountered an error.',
          title: 'Google Sign-In',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  hint: 'Email/Ph number',
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.copper,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.16),
                PrimaryButton(
                  label: _isLoading ? 'Logging in...' : 'Login',
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 20),
                GoogleSignInButton(
                  label: 'Login with google',
                  onPressed: _isLoading ? null : _loginWithGoogle,
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
