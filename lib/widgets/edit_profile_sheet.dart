import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';
import 'app_text_field.dart';
import 'network_image_with_fallback.dart';
import 'primary_button.dart';

/// Modal bottom sheet for editing user profile (Photo, Name, Email, Phone with OTP verification).
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({
    super.key,
    required this.initialProfile,
    this.onProfileUpdated,
  });

  final UserProfile? initialProfile;
  final ValueChanged<UserProfile>? onProfileUpdated;

  static Future<UserProfile?> show(
    BuildContext context, {
    required UserProfile? profile,
    ValueChanged<UserProfile>? onUpdated,
  }) {
    return showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileSheet(
        initialProfile: profile,
        onProfileUpdated: onUpdated,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _otpController;

  late String _selectedPhotoUrl;
  late final String _initialPhone;

  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpSent = false;
  String _verificationId = '';

  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile ?? AuthService.instance.currentUser;
    _nameController = TextEditingController(text: p?.displayName ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _initialPhone = p?.phone.replaceAll(' ', '') ?? '';
    _phoneController = TextEditingController(text: _initialPhone);
    _otpController = TextEditingController();
    _selectedPhotoUrl = (p != null && p.photoUrl.isNotEmpty)
        ? p.photoUrl
        : MockData.userAvatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _isPhoneModified {
    final cleanCurrent = _phoneController.text.replaceAll(' ', '').trim();
    return cleanCurrent.isNotEmpty && cleanCurrent != _initialPhone;
  }

  Future<void> _sendOtpForPhoneChange() async {
    final newPhone = _phoneController.text.trim();
    final digits = newPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      AppBanner.showError(
        context,
        'Please enter a valid 10-digit mobile number.',
        title: 'Invalid Mobile Number',
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    final formattedPhone = newPhone.startsWith('+') ? newPhone : '+91$newPhone';

    try {
      await AuthService.instance.sendFirebasePhoneOtp(
        phoneNumber: formattedPhone,
        onCodeSent: (vid) {
          if (mounted) {
            setState(() {
              _verificationId = vid;
              _otpSent = true;
              _isSendingOtp = false;
            });
            AppBanner.showSuccess(
              context,
              'Verification code dispatched to $formattedPhone!',
              title: 'SMS Sent',
            );
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() => _isSendingOtp = false);
            AppBanner.showInfo(
              context,
              'Note: $err. Check console for test code.',
              title: 'SMS Gateway',
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        AppBanner.showError(context, e.toString());
      }
    }
  }

  Future<void> _verifyOtpAndSavePhone() async {
    final code = _otpController.text.trim();
    if (code.length < 4) {
      AppBanner.showError(
        context,
        'Please enter the complete 6-digit verification code.',
        title: 'Incomplete Code',
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);
    try {
      final updated = await AuthService.instance.verifyAndUpdateUserPhone(
        newPhone: _phoneController.text.trim(),
        verificationId: _verificationId,
        smsCode: code,
      );

      // Now also save name, email, and photo
      final fullyUpdated = await AuthService.instance.updateUserDetails(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _selectedPhotoUrl,
      );

      if (mounted) {
        widget.onProfileUpdated?.call(fullyUpdated);
        AppBanner.showSuccess(
          context,
          'Mobile number and profile updated successfully!',
          title: 'Profile Updated',
        );
        Navigator.of(context).pop(fullyUpdated);
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
        setState(() => _isVerifyingOtp = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.length < 2) {
      AppBanner.showError(
        context,
        'Please enter your full name (at least 2 characters).',
        title: 'Name Required',
      );
      return;
    }

    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      AppBanner.showError(
        context,
        'Please enter a valid email address.',
        title: 'Invalid Email',
      );
      return;
    }

    if (_isPhoneModified && !_otpSent) {
      AppBanner.showInfo(
        context,
        'You modified your mobile number. Please tap "Verify Phone" to confirm via SMS.',
        title: 'Phone Verification Required',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updated = await AuthService.instance.updateUserDetails(
        displayName: name,
        email: email,
        photoUrl: _selectedPhotoUrl,
      );

      if (mounted) {
        widget.onProfileUpdated?.call(updated);
        AppBanner.showSuccess(
          context,
          'Profile details saved successfully!',
          title: 'Profile Saved',
        );
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      if (mounted) {
        AppBanner.showError(context, 'Could not save profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Avatar Section
            Center(
              child: Column(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: NetworkImageWithFallback(
                        url: _selectedPhotoUrl,
                        fallbackIcon: Icons.person,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose Avatar Preset',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _avatarPresets.map((url) {
                      final isSelected = url == _selectedPhotoUrl;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPhotoUrl = url),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.copper : Colors.transparent,
                              width: 2.2,
                            ),
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              width: 38,
                              height: 38,
                              child: NetworkImageWithFallback(
                                url: url,
                                fallbackIcon: Icons.person,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            const Text(
              'FULL NAME',
              style: TextStyle(
                color: AppColors.copper,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'Full Name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            // Email Field
            const Text(
              'EMAIL ADDRESS',
              style: TextStyle(
                color: AppColors.copper,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MOBILE NUMBER',
                  style: TextStyle(
                    color: AppColors.copper,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_isPhoneModified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF332008),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade700, width: 0.8),
                    ),
                    child: Text(
                      'Requires SMS Verification',
                      style: TextStyle(
                        color: Colors.amber.shade300,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                  ),
                ),
                if (_isPhoneModified && !_otpSent) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSendingOtp ? null : _sendOtpForPhoneChange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.copper,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.field),
                      ),
                    ),
                    child: _isSendingOtp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ],
              ],
            ),

            // Inline OTP verification card when phone is changed
            if (_otpSent) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sms_outlined, size: 16, color: AppColors.copper),
                        SizedBox(width: 6),
                        Text(
                          'Enter 6-Digit OTP sent to new number',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: '6-digit OTP',
                            keyboardType: TextInputType.number,
                            controller: _otpController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isVerifyingOtp ? null : _verifyOtpAndSavePhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.field),
                            ),
                          ),
                          child: _isVerifyingOtp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            PrimaryButton(
              label: 'Save Profile Changes',
              isLoading: _isLoading,
              onPressed: _isPhoneModified && !_otpSent ? _sendOtpForPhoneChange : _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
