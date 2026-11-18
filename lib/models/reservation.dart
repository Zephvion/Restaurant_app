import 'restaurant.dart';

/// Reservation lifecycle status.
///
/// These values match the canonical Firestore reservation status contract.
enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  String get value => name;

  static ReservationStatus fromValue(String value) {
    return ReservationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError(
        'Unknown reservation status: $value',
      ),
    );
  }
}

/// A table reservation made by the user.
class Reservation {
  const Reservation({
    required this.id,
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.seats,
    required this.tableNumber,
    this.status = ReservationStatus.confirmed,
  });

  final String id;
  final Restaurant restaurant;
  final DateTime date;
  final String timeSlot;
  final int seats;
  final int tableNumber;
  final ReservationStatus status;

  /// Short human-readable date, e.g. "January 2, 2023".
  String get formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}