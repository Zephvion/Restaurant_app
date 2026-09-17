import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/primary_button.dart';

/// "Verify OTP!" screen with dynamic random OTP simulation, 4-digit code entry,
/// live SMS dispatch banner, 1-tap auto-fill helper, and resend cooldown timer.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  bool _isLoading = false;
  String _activeOtp = '';
  Timer? _timer;
  int _resendCountdown = 30;

  bool get _isComplete => _code.length == 4;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phone = (ModalRoute.of(context)?.settings.arguments as String?) ??
          MockData.demoPhoneNumber;
      _ensureOtpGenerated(phone);
    });
  }

  void _ensureOtpGenerated(String phone) {
    var otp = AuthService.instance.currentOtp;
    if (otp == null || otp.isEmpty) {
      otp = AuthService.instance.generateAndSendOtp(phone: phone, length: 4);
    }
    setState(() => _activeOtp = otp!);
    AppBanner.showInfo(
      context,
      'SMS Verification from PARAGON: Your OTP code is $otp (Valid for 5 minutes).',
      title: '📱 SMS Gateway',
    );
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.verifyOtp(_code);
      if (mounted) {
        final user = AuthService.instance.currentUser;
        final name = user?.displayName.isNotEmpty == true
            ? user!.displayName
            : 'Valued Guest';
        AppBanner.showSuccess(
          context,
          'Phone verified & logged in successfully! Welcome, $name.',
          title: 'Welcome to PARAGON',
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
          e.toString().replaceAll('Exception: ', '').trim(),
          title: 'Verification Failed',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resend() {
    if (_resendCountdown > 0) return;

    final phone = (ModalRoute.of(context)?.settings.arguments as String?) ??
        MockData.demoPhoneNumber;
    final newOtp = AuthService.instance.generateAndSendOtp(phone: phone, length: 4);
    setState(() {
      _activeOtp = newOtp;
      _code = '';
    });
    _startResendTimer();

    AppBanner.showInfo(
      context,
      'A new verification code has been dispatched: $newOtp',
      title: '📱 New SMS Sent',
    );
  }

  void _autoFill() {
    if (_activeOtp.isNotEmpty) {
      setState(() {
        _code = _activeOtp;
      });
      _verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String? ??
        MockData.demoPhoneNumber;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.06),
                    Text(
                      'Verify OTP!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _PhoneRow(
                      phone: phone,
                      onEdit: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 24),

                    // ── Simulated SMS Incoming Notification Card ──────────────
                    if (_activeOtp.isNotEmpty)
                      GestureDetector(
                        onTap: _autoFill,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.copper.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.copper.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mark_email_unread_outlined,
                                  color: AppColors.copper,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PARAGON SMS Code',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Your OTP is $_activeOtp',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.copper,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'AUTO-FILL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: h * 0.06),

                    // ── 4 Single-Digit OTP Blocks ─────────────────────────────
                    OtpInput(
                      length: 4,
                      value: _code,
                      onChanged: (v) => setState(() => _code = v),
                      onCompleted: (v) {
                        setState(() => _code = v);
                        _verify();
                      },
                    ),

                    SizedBox(height: h * 0.05),

                    // ── Resend OTP with Live Cooldown Timer ───────────────────
                    GestureDetector(
                      onTap: _resendCountdown == 0 ? _resend : null,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Resend OTP in ${_resendCountdown}s'
                            : 'Resend OTP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _resendCountdown > 0
                                  ? AppColors.textSecondary
                                  : AppColors.copper,
                              fontWeight: FontWeight.w600,
                              decoration: _resendCountdown == 0
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: AppColors.copper,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sign In Button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isComplete ? 1 : 0.4,
                child: PrimaryButton(
                  label: _isLoading ? 'Verifying...' : 'Verify & Sign In',
                  onPressed: (_isComplete && !_isLoading) ? _verify : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.phone, required this.onEdit});

  final String phone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Enter the 4-digit code sent to '),
                TextSpan(
                  text: phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onEdit,
          child: const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.copper,
          ),
        ),
      ],
    );
  }
}
