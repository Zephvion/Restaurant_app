import 'package:flutter/foundation.dart';

/// A saved delivery address (Home / Office) shown on the cart, billing and
/// account screens.
@immutable
class Address {
  const Address({
    required this.label,
    required this.details,
    this.isDefault = false,
  });

  /// Short label — "Home", "Office".
  final String label;

  /// Full address line.
  final String details;

  final bool isDefault;
}
