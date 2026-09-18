import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/google_auth_service.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';
import 'google_sign_in_button.dart';

/// Shows an authentic Google Account Chooser bottom sheet modal.
Future<void> showGoogleAccountPickerSheet(
  BuildContext context, {
  VoidCallback? onSuccess,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GoogleAccountPickerModal(onSuccess: onSuccess),
  );
}

class _GoogleAccountPickerModal extends StatefulWidget {
  const _GoogleAccountPickerModal({this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  State<_GoogleAccountPickerModal> createState() => _GoogleAccountPickerModalState();
}

class _GoogleAccountPickerModalState extends State<_GoogleAccountPickerModal> {
  bool _isSigningIn = false;
  String? _signingInEmail;

  Future<void> _handleAccountSelected(GoogleUserProfile account) async {
    setState(() {
      _isSigningIn = true;
      _signingInEmail = account.email;
    });

    // Brief authentic Google authentication handshake delay
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    GoogleAuthService.instance.signIn(account);

    Navigator.of(context).pop(); // Close bottom sheet

    // Show confirmation toast
    AppToast.showSuccess(
      context,
      'Signed in as ${account.email}',
      title: 'Google Sign-In',
    );

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  void _showAddCustomAccountDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: '@gmail.com');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            GoogleLogo(size: 20),
            SizedBox(width: 10),
            Text(
              'Add Google Account',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'e.g. Sindhu K',
                  hintStyle: const TextStyle(color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.backgroundElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Google Email',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'e.g. user@gmail.com',
                  hintStyle: const TextStyle(color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.backgroundElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop();
                GoogleAuthService.instance.signInWithCustomAccount(
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                );
                final newAccount = GoogleAuthService.instance.currentUser!;
                _handleAccountSelected(newAccount);
              }
            },
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = GoogleAuthService.instance.availableAccounts;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
          left: BorderSide(color: AppColors.border, width: 1),
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Top drag pill handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header with Google Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const GoogleLogo(size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign in with Google',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose an account to continue to PARAGON',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),

              if (_isSigningIn) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Signing in with Google...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      if (_signingInEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _signingInEmail!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                // Account options
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: AppColors.border,
                    height: 1,
                    indent: 68,
                  ),
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return InkWell(
                      onTap: () => _handleAccountSelected(acc),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: acc.avatarColor,
                              child: Text(
                                acc.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.displayName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    acc.email,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.hint,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Divider(color: AppColors.border, height: 1),

                // Use another account button
                InkWell(
                  onTap: _showAddCustomAccountDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Use another account',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: AppColors.border, height: 1),

                // Disclaimer / Terms
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: Text(
                    "To continue, Google will share your name, email address, and profile picture with PARAGON. See PARAGON's Privacy Policy and Terms of Service.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                          fontSize: 11,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
