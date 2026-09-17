import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/google_account_picker_sheet.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/primary_button.dart';

/// Modern 10/10 End-to-End Registration Screen.
/// Captures full personal details, delivery address & landmark with GPS auto-detection,
/// security credentials, and routes to OTP verification.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _detectLocation() {
    final currentArea = LocationService.instance.currentDeliveryArea;
    if (_landmarkController.text.trim().isEmpty) {
      _landmarkController.text = currentArea.isNotEmpty ? currentArea : 'Palazhi, Calicut';
    }
    if (_addressController.text.trim().isEmpty) {
      _addressController.text = 'Flat 4B, Emerald Heights, Hilite City';
    }
    AppBanner.showInfo(
      context,
      'Location detected: ${currentArea.isNotEmpty ? currentArea : "Palazhi, Calicut"}',
      title: 'GPS Location',
    );
  }

  void _openAddressPicker() {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) {
        setState(() {
          _landmarkController.text = addr.label;
          _addressController.text = addr.details;
        });
      },
    );
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_agreeToTerms) {
      AppBanner.showError(
        context,
        'Please agree to the Terms of Service & Privacy Policy to continue.',
        title: 'Agreement Required',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressDetails: _addressController.text.trim(),
        landmark: _landmarkController.text.trim(),
        cityArea: _landmarkController.text.trim().isNotEmpty
            ? _landmarkController.text.trim()
            : 'Palazhi , Calicut',
      );

      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Account created! Please verify the OTP sent to your phone.',
          title: 'Welcome to PARAGON',
        );
        Navigator.of(context).pushNamed(
          AppRoutes.otp,
          arguments: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : '+91 9874563210',
        );
      }
    } catch (e) {
      if (mounted) {
        AppBanner.showError(
          context,
          'Registration failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _signInWithGoogle() {
    showGoogleAccountPickerSheet(
      context,
      onSuccess: () {
        AppBanner.showSuccess(
          context,
          'Signed in successfully with Google!',
          title: 'Welcome Back',
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      },
    );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create an Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join PARAGON for exceptional culinary experiences',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),

                // ── Section 1: Personal Details ──────────────────────────────
                _buildSectionHeader('1. Personal Details', Icons.person_outline),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Full Name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Full Name is required';
                    if (v.trim().length < 2) return 'Enter a valid name';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Mobile Number (+91)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                    final clean = v.replaceAll(RegExp(r'\D'), '');
                    if (clean.length < 10) return 'Enter a valid 10-digit mobile number';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ── Section 2: Delivery Location & Address ────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('2. Delivery Location', Icons.location_on_outlined),
                    TextButton.icon(
                      onPressed: _detectLocation,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.copper,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.my_location, size: 14),
                      label: const Text('Detect GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Flat / House No. / Building / Street',
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.streetAddressLine1],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Delivery address is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Nearest Landmark / Area (e.g. Palazhi, Near Hilite)',
                  controller: _landmarkController,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Landmark / Area is required';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ── Section 3: Security & Password ───────────────────────────
                _buildSectionHeader('3. Account Security', Icons.lock_outline),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Password (min. 6 characters)',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ── Terms & Conditions Checkbox ──────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppColors.copper,
                        checkColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: AppColors.hint),
                        onChanged: (val) => setState(() => _agreeToTerms = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                PrimaryButton(
                  label: _isLoading ? 'Creating Account...' : 'Sign Up & Verify OTP',
                  onPressed: _isLoading ? null : _register,
                ),
                const SizedBox(height: 16),
                GoogleSignInButton(
                  label: 'Sign in with Google',
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 20),
                _LoginPrompt(onTap: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.copper),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.copper,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Login',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
