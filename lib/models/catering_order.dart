/// Progression states for a catering request matching Figma design.
enum CateringStatus {
  notifiedParagon,
  call,
  bookingConfirmed,
}

/// A catering order placed by the user.
class CateringOrder {
  CateringOrder({
    required this.id,
    required this.date,
    required this.guestRange,
    this.status = CateringStatus.notifiedParagon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'ID4578'
  final DateTime date;
  final String guestRange; // e.g. 'Less than 100'
  CateringStatus status;
  final DateTime createdAt;

  /// Short human-readable date, e.g. "January 2 , 2023"
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day} , ${date.year}';
  }

  /// Status badge label
  String get statusLabel {
    switch (status) {
      case CateringStatus.notifiedParagon:
        return 'Waiting for the call from Paragon';
      case CateringStatus.call:
        return 'Call scheduled';
      case CateringStatus.bookingConfirmed:
        return 'Booking Confirmed';
    }
  }
}
