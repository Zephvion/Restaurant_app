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
  String _phone = MockData.demoPhoneNumber;
  String _verificationId = '';
  String? _displayName;
  String? _email;
  Timer? _timer;
  int _resendCountdown = 30;

  bool get _isComplete => _code.length == 6 || _code.length == 4;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _parseArgumentsAndSendOtp();
    });
  }

  void _parseArgumentsAndSendOtp() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phone = args['phone'] as String? ?? MockData.demoPhoneNumber;
      _verificationId = args['verificationId'] as String? ?? '';
      _displayName = args['name'] as String?;
      _email = args['email'] as String?;
    } else if (args is String) {
      _phone = args;
      _verificationId = AuthService.instance.verificationId ?? '';
    }

    if (_verificationId.isEmpty) {
      _sendPhoneOtp();
    }
  }

  Future<void> _sendPhoneOtp() async {
    setState(() => _isLoading = true);
    await AuthService.instance.sendFirebasePhoneOtp(
      phoneNumber: _phone,
      onCodeSent: (vid) {
        if (mounted) {
          setState(() {
            _verificationId = vid;
            _isLoading = false;
          });
          AppBanner.showSuccess(
            context,
            'SMS code sent to $_phone. Please enter the 6-digit verification code.',
            title: 'SMS Sent',
          );
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppBanner.showError(
            context,
            err,
            title: 'SMS Delivery Failed',
          );
        }
      },
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
      if (_verificationId.isNotEmpty) {
        await AuthService.instance.verifyFirebasePhoneOtp(
          verificationId: _verificationId,
          smsCode: _code,
          displayName: _displayName,
          email: _email,
        );
      } else {
        await AuthService.instance.verifyOtp(_code);
      }

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
    setState(() {
      _code = '';
    });
    _startResendTimer();
    _sendPhoneOtp();
  }

  @override
  Widget build(BuildContext context) {
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
                      phone: _phone,
                      onEdit: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Please enter the 6-digit verification code sent to your phone number.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                    ),
                    SizedBox(height: h * 0.06),

                    // ── 6 Single-Digit OTP Blocks ─────────────────────────────
                    OtpInput(
                      length: 6,
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
                const TextSpan(text: 'Enter the 6-digit code sent to '),
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
