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
  bool _useOtpMode = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_useOtpMode) {
      await _sendOtp();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.instance.signInWithIdentifier(
        identifier: _identifier.text.trim(),
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
          'Login failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').replaceAll('Exception: ', '').trim()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    final raw = _identifier.text.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      AppBanner.showError(
        context,
        'Please enter a valid 10-digit mobile number.',
        title: 'Invalid Mobile Number',
      );
      return;
    }

    final formatted = digits.length == 10
        ? '+91$digits'
        : (raw.startsWith('+') ? raw : '+$raw');

    setState(() => _isLoading = true);
    await AuthService.instance.sendFirebasePhoneOtp(
      phoneNumber: formatted,
      onCodeSent: (vid) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppBanner.showSuccess(
            context,
            'Verification code sent to $formatted',
            title: 'OTP Dispatched',
          );
          Navigator.of(context).pushNamed(
            AppRoutes.otp,
            arguments: {
              'phone': formatted,
              'verificationId': vid,
            },
          );
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppBanner.showError(
            context,
            err,
            title: 'SMS Delivery Notice',
          );
          // Navigate to OTP screen with fallback test verification ID
          Navigator.of(context).pushNamed(
            AppRoutes.otp,
            arguments: {
              'phone': formatted,
              'verificationId': AuthService.instance.verificationId ?? 'fallback_vid',
            },
          );
        }
      },
    );
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
                SizedBox(height: h * 0.08),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _useOtpMode
                      ? 'Sign in using your mobile number and OTP'
                      : 'Sign in with your Email / Mobile and password',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: h * 0.06),

                // ── Identifier Field (Email or Mobile) ─────────────────────────
                AppTextField(
                  hint: _useOtpMode ? 'Mobile Number (e.g. 9874563210)' : 'Email / Mobile number',
                  controller: _identifier,
                  keyboardType: _useOtpMode
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  textInputAction: _useOtpMode ? TextInputAction.done : TextInputAction.next,
                  autofillHints: _useOtpMode
                      ? const [AutofillHints.telephoneNumber]
                      : const [AutofillHints.username],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (_useOtpMode) {
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) return 'Enter 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password Field (Hidden in OTP Mode) ────────────────────────
                if (!_useOtpMode) ...[
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Toggle to OTP mode
                      GestureDetector(
                        onTap: () => setState(() => _useOtpMode = true),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Login via Phone OTP',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Forgot password
                      GestureDetector(
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
                    ],
                  ),
                ] else ...[
                  // In OTP Mode: Option to switch back to Password mode
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => setState(() => _useOtpMode = false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '← Sign in with Password instead',
                          style: TextStyle(
                            color: AppColors.copper,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: h * 0.10),

                // ── Primary Action Button ─────────────────────────────────────
                PrimaryButton(
                  label: _isLoading
                      ? (_useOtpMode ? 'Sending OTP...' : 'Logging in...')
                      : (_useOtpMode ? 'Send OTP to Mobile' : 'Login'),
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 20),

                // ── Google Sign-In ────────────────────────────────────────────
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
