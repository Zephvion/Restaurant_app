import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Type of in-app banner/toast notification.
enum BannerType { success, error, info }

/// High-visibility floating top banner / notification toast.
class AppBanner {
  static void show(
    BuildContext context, {
    required String message,
    BannerType type = BannerType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // Fallback to SnackBar if overlay not readily accessible
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          backgroundColor: type == BannerType.success
              ? const Color(0xFF1E3A2B)
              : type == BannerType.error
                  ? const Color(0xFF4A1818)
                  : AppColors.backgroundElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: type == BannerType.success
                  ? const Color(0xFF3FA34D)
                  : type == BannerType.error
                      ? AppColors.accentRed
                      : AppColors.copper,
              width: 1.2,
            ),
          ),
          content: Row(
            children: [
              Icon(
                type == BannerType.success
                    ? Icons.check_circle_rounded
                    : type == BannerType.error
                        ? Icons.error_outline_rounded
                        : Icons.info_outline_rounded,
                color: type == BannerType.success
                    ? const Color(0xFF4ADE80)
                    : type == BannerType.error
                        ? const Color(0xFFFF6B6B)
                        : AppColors.copper,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: duration,
        ),
      );
      return;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _TopBannerWidget(
        title: title,
        message: message,
        type: type,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Success',
      type: BannerType.success,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Alert',
      type: BannerType.error,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Notice',
      type: BannerType.info,
    );
  }
}

class _TopBannerWidget extends StatefulWidget {
  const _TopBannerWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.title,
  });

  final String message;
  final String? title;
  final BannerType type;
  final VoidCallback onDismiss;

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top > 0 ? media.padding.top + 8 : 24.0;

    final Color borderColor;
    final Color bgColor;
    final Color iconColor;
    final IconData iconData;

    switch (widget.type) {
      case BannerType.success:
        borderColor = const Color(0xFF3FA34D);
        bgColor = const Color(0xFF14291D);
        iconColor = const Color(0xFF4ADE80);
        iconData = Icons.check_circle_rounded;
        break;
      case BannerType.error:
        borderColor = AppColors.accentRed;
        bgColor = const Color(0xFF2E1212);
        iconColor = const Color(0xFFFF6B6B);
        iconData = Icons.error_outline_rounded;
        break;
      case BannerType.info:
        borderColor = AppColors.copper;
        bgColor = AppColors.backgroundElevated;
        iconColor = AppColors.copper;
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

