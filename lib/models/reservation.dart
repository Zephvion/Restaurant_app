import 'restaurant.dart';

/// A confirmed table reservation made by the user.
class Reservation {
  const Reservation({
    required this.id,
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.seats,
    required this.tableNumber,
  });

  final String id;
  final Restaurant restaurant;
  final DateTime date;
  final String timeSlot; // e.g. "7:00AM"
  final int seats;
  final int tableNumber;

  /// Short human-readable date, e.g. "January 2, 2023"
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day} , ${date.year}';
  }
}
