import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/primary_button.dart';

/// "Verify OTP!" screen with a 4-digit code entry. The Sign In button appears
/// once all four digits are entered (matching the Figma states).
/// "Verify OTP!" screen wired to Firebase AuthService.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  bool _isLoading = false;

  bool get _isComplete => _code.length == 4;

  Future<void> _verify() async {

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.verifyOtp(_code);
      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Phone verified & logged in successfully!',
          title: 'Welcome',
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
          'OTP verification failed: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resend() {
    AppBanner.showInfo(
      context,
      'A new OTP code has been sent.',
      title: 'Code Sent',
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone =
        ModalRoute.of(context)?.settings.arguments as String? ??
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
                    SizedBox(height: h * 0.10),
                    Text(
                      'Verify OTP!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    _PhoneRow(
                      phone: phone,
                      onEdit: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(height: h * 0.10),
                    OtpInput(
                      onChanged: (v) => setState(() => _code = v),
                      onCompleted: (v) => setState(() => _code = v),
                    ),
                    SizedBox(height: h * 0.06),
                    GestureDetector(
                      onTap: _resend,
                      child: Text(
                        'Resend OTP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sign In button — fades in once the code is complete.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isComplete ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_isComplete || _isLoading,
                  child: PrimaryButton(
                    label: _isLoading ? 'Verifying...' : 'Sign In',
                    onPressed: _verify,
                  ),
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
                const TextSpan(text: 'Enter the OTP sent to '),
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
          child: const Icon(Icons.edit_outlined,
              size: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
