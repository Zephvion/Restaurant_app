import 'package:flutter/widgets.dart';

/// A single onboarding slide: two collage photos, a title and a subtitle.
@immutable
class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.frontImage,
    required this.backImage,
  });

  final String title;
  final String subtitle;

  /// The larger, front image in the tilted collage.
  final String frontImage;

  /// The smaller, offset image behind it.
  final String backImage;
}
