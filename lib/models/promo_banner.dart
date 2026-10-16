import 'package:flutter/material.dart';

enum PromoBannerStyle {
  gourmet,
  healthy,
  palace,
}

/// A promotional card in the home-screen carousel styled after Swiggy offer cards,
/// blending seamlessly into the dark page background.
@immutable
class PromoBanner {
  const PromoBanner({
    required this.headline,
    required this.code,
    required this.imageUrl,
    this.tag = 'PARAGON SPECIAL',
    this.subtitle,
    this.buttonText = 'ORDER NOW',
    this.accentColor,
    this.gradientColors,
    this.style = PromoBannerStyle.palace,
  });

  /// Large offer text, e.g. "FLAT ₹50 OFF", "GET 10% OFF".
  final String headline;

  /// Coupon code shown under the headline, e.g. "PARAGON50".
  final String code;

  /// Food dish image on the right side of the card.
  final String imageUrl;

  /// Top brand/tagline, e.g. "gourmet FOOD FESTIVAL", "High Fibre", "Paragon Palace".
  final String tag;

  /// Description/terms, e.g. "Unlock the extraordinary", "on delicious authentic dishes".
  final String? subtitle;

  /// Button label, defaults to "ORDER NOW".
  final String buttonText;

  /// Theme accent color for the button / tag.
  final Color? accentColor;

  /// Custom background gradient colors blending into the app background.
  final List<Color>? gradientColors;

  /// Visual presentation style matching the Swiggy cards.
  final PromoBannerStyle style;

  String get title => headline;
  String get displaySubtitle => subtitle ?? 'Use code $code';

  Map<String, dynamic> toMap() => {
        'headline': headline,
        'code': code,
        'imageUrl': imageUrl,
        'tag': tag,
        'subtitle': subtitle,
        'title': headline,
        'buttonText': buttonText,
        'style': style.name,
      };

  factory PromoBanner.fromMap(Map<String, dynamic> map) {
    PromoBannerStyle parseStyle(String? val) {
      if (val == 'gourmet') return PromoBannerStyle.gourmet;
      if (val == 'healthy') return PromoBannerStyle.healthy;
      return PromoBannerStyle.palace;
    }

    return PromoBanner(
      headline: map['headline'] as String? ?? map['title'] as String? ?? '',
      code: map['code'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      tag: map['tag'] as String? ?? 'PARAGON SPECIAL',
      subtitle: map['subtitle'] as String?,
      buttonText: map['buttonText'] as String? ?? 'ORDER NOW',
      style: parseStyle(map['style'] as String?),
    );
  }
}

