import 'restaurant.dart';

/// A confirmed table reservation made by the user.
class Reservation {
  const Reservation({
    required this.id,
    this.userId = '',
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.seats,
    required this.tableNumber,
    this.status = 'confirmed',
  });

  final String id;
  final String userId;
  final Restaurant restaurant;
  final DateTime date;
  final String timeSlot; // e.g. "7:00AM"
  final int seats;
  final int tableNumber;
  final String status;

  /// Short human-readable date, e.g. "January 2, 2023"
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day} , ${date.year}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'restaurant': restaurant.toMap(),
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'seats': seats,
        'tableNumber': tableNumber,
        'status': status,
      };

  factory Reservation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Reservation(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      restaurant: map['restaurant'] != null
          ? Restaurant.fromMap(Map<String, dynamic>.from(map['restaurant'] as Map))
          : const Restaurant(
              id: 'rest_1',
              name: 'Paragon Restaurant',
              address: 'Kannur Road, Near CH Flyover',
              city: 'Calicut',
            ),
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? '7:00PM',
      seats: (map['seats'] as num?)?.toInt() ?? 2,
      tableNumber: (map['tableNumber'] as num?)?.toInt() ?? 1,
      status: map['status'] as String? ?? 'confirmed',
    );
  }
}
