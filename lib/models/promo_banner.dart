import 'package:flutter/foundation.dart';

/// A promotional card in the home-screen carousel
/// (e.g. "GET 10% OFF — use code WELCOMEBACK").
@immutable
class PromoBanner {
  const PromoBanner({
    required this.headline,
    required this.code,
    required this.imageUrl,
  });

  /// Large offer text, e.g. "GET 10% OFF".
  final String headline;

  /// Coupon code shown under the headline.
  final String code;

  final String imageUrl;

  String get title => headline;
  String get subtitle => 'Use code $code';
  String get buttonText => 'ORDER NOW';

  Map<String, dynamic> toMap() => {
        'headline': headline,
        'code': code,
        'imageUrl': imageUrl,
        'title': headline,
        'subtitle': 'Use code $code',
        'buttonText': 'ORDER NOW',
      };

  factory PromoBanner.fromMap(Map<String, dynamic> map) {
    return PromoBanner(
      headline: map['headline'] as String? ?? map['title'] as String? ?? '',
      code: map['code'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}
