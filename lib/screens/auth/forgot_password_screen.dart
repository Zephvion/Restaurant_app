import 'dart:async';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Password recovery screen enabling users to request a password reset email link
/// with countdown timer, clean email validation, and modern feedback banners.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _resendCooldown = 0);
        timer.cancel();
      }
    });
  }

  Future<void> _sendResetLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await AuthService.instance.sendPasswordResetEmail(email);

      if (mounted) {
        setState(() {
          _isSent = true;
        });
        _startCooldownTimer();
        AppBanner.showSuccess(
          context,
          'Password reset link sent to $email.',
          title: 'Reset Link Sent',
        );
      }
    } catch (e) {
      if (mounted) {
        AppBanner.showError(
          context,
          'Failed to send reset link: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isSent ? _buildSuccessView(h) : _buildFormView(h),
        ),
      ),
    );
  }

  Widget _buildFormView(double h) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: h * 0.04),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.maroon.withOpacity(0.4),
                    AppColors.copper.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.copper.withOpacity(0.5)),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.copper,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            "Don't worry! Enter your registered email address and we'll send you instructions to reset your password.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          SizedBox(height: h * 0.06),
          AppTextField(
            hint: 'Registered Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _sendResetLink(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
              return null;
            },
          ),
          SizedBox(height: h * 0.05),
          PrimaryButton(
            label: _isLoading ? 'Sending Link...' : 'Send Reset Link',
            onPressed: _isLoading ? null : _sendResetLink,
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: AppColors.copper),
                    const SizedBox(width: 6),
                    Text(
                      'Back to Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.copper,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessView(double h) {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: h * 0.05),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withOpacity(0.15),
              border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.6), width: 1.5),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: Color(0xFF22C55E),
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
            children: [
              const TextSpan(text: "We've dispatched a password reset link to\n"),
              TextSpan(
                text: email,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ".\nPlease check your inbox and spam folder."),
            ],
          ),
        ),
        SizedBox(height: h * 0.06),
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _resendCooldown > 0 || _isLoading ? null : _sendResetLink,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.copper),
            label: Text(
              _resendCooldown > 0
                  ? 'Resend link in ${_resendCooldown}s'
                  : 'Did not receive email? Resend',
              style: TextStyle(
                color: _resendCooldown > 0 ? AppColors.hint : AppColors.copper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

