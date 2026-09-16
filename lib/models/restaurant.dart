/// A Paragon restaurant branch that can be selected for a table reservation.
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String? logoUrl;
}
