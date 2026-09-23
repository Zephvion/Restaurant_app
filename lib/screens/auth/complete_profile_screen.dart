import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/gps_detection_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gps_location_picker_sheet.dart';
import '../../widgets/primary_button.dart';

/// 10/10 Complete Profile Screen.
/// Shown right after Phone OTP verification for newly registered phone numbers
/// or accounts with incomplete profiles.
class CompleteProfileScreen extends StatefulWidget {
  final String? initialPhone;

  const CompleteProfileScreen({super.key, this.initialPhone});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isDetectingLocation = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double? _detectedLat;
  double? _detectedLng;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _phone = widget.initialPhone ?? user?.phone ?? AuthService.instance.otpPhoneNumber ?? '';
    if (user != null) {
      if (user.displayName.isNotEmpty && user.displayName != 'Valued Guest' && user.displayName != 'User') {
        _nameController.text = user.displayName;
      }
      if (user.email.isNotEmpty && !user.email.contains('@paragon.com')) {
        _emailController.text = user.email;
      }
      if (user.savedAddresses.isNotEmpty) {
        final firstAddr = user.savedAddresses.first;
        _addressController.text = firstAddr.details;
        _landmarkController.text = firstAddr.label;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      final location = await GpsDetectionService.instance.detectLiveLocation();
      if (!mounted) return;

      setState(() {
        _isDetectingLocation = false;
        _detectedLat = location.lat;
        _detectedLng = location.lng;
        _addressController.text = location.details;
        _landmarkController.text = location.label;
      });

      await LocationService.instance.updateDeliveryArea(location.label);

      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Live GPS Locked: ${location.label}',
          title: 'Location Detected',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
        AppBanner.showError(
          context,
          'Could not detect live location. Please pick on the map.',
          title: 'GPS Notice',
        );
      }
    }
  }

  Future<void> _openMapPicker() async {
    final currentLat = _detectedLat ?? 12.9753;
    final currentLng = _detectedLng ?? 77.5910;
    final currentLabel = _landmarkController.text.trim().isNotEmpty
        ? _landmarkController.text.trim()
        : 'Selected Location';
    final currentDetails = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : 'Doorstep Delivery Location';

    await GpsLocationPickerSheet.show(
      context: context,
      initialAddress: Address(
        id: 'complete_profile_map',
        label: currentLabel,
        details: currentDetails,
        lat: currentLat,
        lng: currentLng,
      ),
      onAddressSelected: (addr) {
        setState(() {
          _detectedLat = addr.lat;
          _detectedLng = addr.lng;
          _landmarkController.text = addr.label;
          _addressController.text = addr.details;
        });
        AppBanner.showSuccess(
          context,
          'Delivery location set to ${addr.label}',
          title: 'Location Confirmed',
        );
      },
    );
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (password.isNotEmpty && password != confirm) {
      AppBanner.showError(
        context,
        'Passwords do not match. Please verify both password fields.',
        title: 'Password Mismatch',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();
      final landmark = _landmarkController.text.trim();

      await AuthService.instance.completeUserProfile(
        displayName: name,
        email: email,
        addressDetails: address,
        landmark: landmark,
        cityArea: landmark.isNotEmpty ? landmark : 'Palazhi , Calicut',
        lat: _detectedLat,
        lng: _detectedLng,
        password: password.isNotEmpty ? password : null,
      );

      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Profile completed successfully! Welcome to PARAGON, $name.',
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
          'Could not complete profile: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipForNow() {
    final user = AuthService.instance.currentUser;
    final fallbackName = user?.displayName.isNotEmpty == true &&
            user!.displayName != 'Valued Guest' &&
            user.displayName != 'User'
        ? user.displayName
        : 'Guest User';

    AppBanner.showSuccess(
      context,
      'Welcome to PARAGON! You can update your profile anytime in Account.',
      title: 'Welcome',
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Complete Your Profile',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skipForNow,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, size: 14, color: AppColors.copper),
                      SizedBox(width: 6),
                      Text(
                        'NEW ACCOUNT SETUP',
                        style: TextStyle(
                          color: AppColors.copper,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Let's get you set up",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add your details to enjoy seamless doorstep delivery and order tracking.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Verified Phone Pill
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10281E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1B5E20), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFIED MOBILE NUMBER',
                              style: TextStyle(
                                color: Colors.greenAccent.shade200,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _phone.isNotEmpty ? _phone : '+91 Verified Mobile',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white38),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Personal Info Section
                const Text(
                  'PERSONAL DETAILS',
                  style: TextStyle(
                    color: AppColors.copper,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Full Name *',
                  controller: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Please enter your full name (min 2 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Email Address *',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Delivery Location Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DELIVERY DOORSTEP',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: _isDetectingLocation ? null : _detectLocation,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.copper.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                if (_isDetectingLocation)
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.copper,
                                    ),
                                  )
                                else
                                  const Icon(Icons.my_location_rounded, size: 12, color: AppColors.copper),
                                const SizedBox(width: 4),
                                const Text(
                                  'GPS',
                                  style: TextStyle(
                                    color: AppColors.copper,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _openMapPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.map_outlined, size: 12, color: Colors.white70),
                                SizedBox(width: 4),
                                Text(
                                  'Map',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'House / Flat / Street Details',
                  controller: _addressController,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Locality / Area / Landmark',
                  controller: _landmarkController,
                ),
                const SizedBox(height: 24),

                // Optional Password Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18, color: AppColors.copper),
                          SizedBox(width: 8),
                          Text(
                            'Set Account Password (Optional)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Allows you to sign in anytime with your Mobile & Password without waiting for SMS verification.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        hint: 'Password (min 6 chars)',
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hint: 'Confirm Password',
                        isPassword: true,
                        controller: _confirmPasswordController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                PrimaryButton(
                  label: 'Save & Continue to Menu',
                  isLoading: _isLoading,
                  onPressed: _saveAndContinue,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _skipForNow,
                    child: const Text(
                      'I will complete this later',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

