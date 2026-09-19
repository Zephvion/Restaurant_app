/// A Paragon restaurant branch that can be selected for a table reservation.
/// A Paragon restaurant branch that can be selected for a table reservation or takeaway.
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.lat = 11.2588,
    this.lng = 75.7804,
    this.logoUrl,
    this.rating = 4.8,
    this.openTime = '11:00 AM',
    this.closeTime = '11:00 PM',
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final String? logoUrl;
  final double rating;
  final String openTime;
  final String closeTime;

  String get branch => address.isNotEmpty ? address : city;
  String? get imageUrl => logoUrl;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'lat': lat,
        'lng': lng,
        'logoUrl': logoUrl,
        'rating': rating,
        'openTime': openTime,
        'closeTime': closeTime,
      };

  factory Restaurant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Restaurant(
      id: id ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 11.2588,
      lng: (map['lng'] as num?)?.toDouble() ?? 75.7804,
      logoUrl: map['logoUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      openTime: map['openTime'] as String? ?? '11:00 AM',
      closeTime: map['closeTime'] as String? ?? '11:00 PM',
    );
  }
}
