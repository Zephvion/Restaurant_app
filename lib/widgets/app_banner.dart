import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Type of in-app banner/toast notification.
enum BannerType { success, error, info }

/// High-visibility floating banner and toast notification system.
class AppBanner {
  static void show(
    BuildContext context, {
    required String message,
    BannerType type = BannerType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppToast.show(
      context,
      message: message,
      title: title,
      type: type,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    AppToast.showSuccess(context, message, title: title);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
  }) {
    AppToast.showError(context, message, title: title);
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
  }) {
    AppToast.showInfo(context, message, title: title);
  }
}

/// Unified, high-contrast Toast helper for displaying visible notifications.
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    BannerType type = BannerType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color borderColor;
    final Color bgColor;
    final Color iconColor;
    final IconData iconData;

    switch (type) {
      case BannerType.success:
        borderColor = const Color(0xFF4ADE80);
        bgColor = const Color(0xFF132F20);
        iconColor = const Color(0xFF4ADE80);
        iconData = Icons.check_circle_rounded;
        break;
      case BannerType.error:
        borderColor = const Color(0xFFFF5252);
        bgColor = const Color(0xFF381414);
        iconColor = const Color(0xFFFF6B6B);
        iconData = Icons.error_outline_rounded;
        break;
      case BannerType.info:
        borderColor = AppColors.copper;
        bgColor = const Color(0xFF2C2219);
        iconColor = AppColors.copper;
        iconData = Icons.info_outline_rounded;
        break;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 85),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null && title.isNotEmpty) ...[
                        Text(
                          title,
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
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // Overlay fallback if ScaffoldMessenger not accessible
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

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
        borderColor = const Color(0xFF4ADE80);
        bgColor = const Color(0xFF132F20);
        iconColor = const Color(0xFF4ADE80);
        iconData = Icons.check_circle_rounded;
        break;
      case BannerType.error:
        borderColor = const Color(0xFFFF5252);
        bgColor = const Color(0xFF381414);
        iconColor = const Color(0xFFFF6B6B);
        iconData = Icons.error_outline_rounded;
        break;
      case BannerType.info:
        borderColor = AppColors.copper;
        bgColor = const Color(0xFF2C2219);
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
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
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                        color: Colors.white70,
                        size: 20,
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
