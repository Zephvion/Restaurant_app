import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/google_account_picker_sheet.dart';
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
      await AuthService.instance.signInWithEmail(
        email: _identifier.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithGoogle() {
    showGoogleAccountPickerSheet(
      context,
      onAccountSelected: () async {
        setState(() => _isLoading = true);
        await AuthService.instance.signInWithGoogle();
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      },
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
                SizedBox(height: h * 0.22),
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
