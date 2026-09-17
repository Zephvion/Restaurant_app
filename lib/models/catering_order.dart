/// Progression states for a catering request matching Figma design.
enum CateringStatus {
  notifiedParagon,
  call,
  bookingConfirmed,
  bookingConfirmed;

  static CateringStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'call':
        return CateringStatus.call;
      case 'bookingconfirmed':
      case 'booking_confirmed':
        return CateringStatus.bookingConfirmed;
      case 'notifiedparagon':
      default:
        return CateringStatus.notifiedParagon;
    }
  }
}

/// A catering order placed by the user.
class CateringOrder {
  CateringOrder({
    required this.id,
    this.userId = '',
    required this.date,
    required this.guestRange,
    this.status = CateringStatus.notifiedParagon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'ID4578'
  final String userId;
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'guestRange': guestRange,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CateringOrder.fromMap(Map<String, dynamic> map, {String? id}) {
    return CateringOrder(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      guestRange: map['guestRange'] as String? ?? 'Less than 100',
      status: CateringStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
