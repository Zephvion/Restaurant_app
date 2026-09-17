import 'package:flutter/foundation.dart';

/// A saved delivery address (Home / Office) shown on the cart, billing and
/// account screens.
@immutable
class Address {
  const Address({
    this.id = '',
    required this.label,
    required this.details,
    this.lat = 11.2588,
    this.lng = 75.7804,
    this.isDefault = false,
  });

  final String id;

  /// Short label — "Home", "Office".
  final String label;

  /// Full address line.
  final String details;

  final double lat;
  final double lng;

  final bool isDefault;

  Address copyWith({
    String? id,
    String? label,
    String? details,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      details: details ?? this.details,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'details': details,
        'lat': lat,
        'lng': lng,
        'isDefault': isDefault,
      };

  factory Address.fromMap(Map<String, dynamic> map, {String? id}) {
    return Address(
      id: id ?? (map['id'] as String? ?? ''),
      label: map['label'] as String? ?? 'Address',
      details: map['details'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 11.2588,
      lng: (map['lng'] as num?)?.toDouble() ?? 75.7804,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}
