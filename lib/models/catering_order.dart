/// Progression states for a catering request matching Figma design.
enum CateringStatus {
  notifiedParagon,
  call,
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

/// A comprehensive enterprise catering order placed by the user.
class CateringOrder {
  CateringOrder({
    required this.id,
    this.userId = '',
    this.restaurantId = 'rest_calicut',
    this.restaurantName = 'Paragon Restaurant - Calicut',
    this.branchLocation = 'Mavoor Road, Calicut',
    required this.date,
    this.timeSlot = 'Lunch (12:00 PM – 3:30 PM)',
    required this.guestRange,
    this.eventType = 'Corporate Buffet',
    this.menuPackage = 'Royal Malabar Feast',
    this.pricePerPlate = 450.0,
    this.venueAddress = 'Palazhi, Calicut',
    this.specialInstructions = '',
    this.contactPhone = '+91 9874563210',
    this.status = CateringStatus.notifiedParagon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'CAT-4578'
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String branchLocation;
  final DateTime date;
  final String timeSlot;
  final String guestRange; // e.g. '100 - 250 Guests'
  final String eventType; // e.g. 'Wedding Reception'
  final String menuPackage; // e.g. 'Royal Malabar Feast'
  final double pricePerPlate;
  final String venueAddress;
  final String specialInstructions;
  final String contactPhone;
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
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'branchLocation': branchLocation,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'guestRange': guestRange,
        'eventType': eventType,
        'menuPackage': menuPackage,
        'pricePerPlate': pricePerPlate,
        'venueAddress': venueAddress,
        'specialInstructions': specialInstructions,
        'contactPhone': contactPhone,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CateringOrder.fromMap(Map<String, dynamic> map, {String? id}) {
    return CateringOrder(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      restaurantId: map['restaurantId'] as String? ?? 'rest_calicut',
      restaurantName: map['restaurantName'] as String? ?? 'Paragon Restaurant - Calicut',
      branchLocation: map['branchLocation'] as String? ?? 'Mavoor Road, Calicut',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? 'Lunch (12:00 PM – 3:30 PM)',
      guestRange: map['guestRange'] as String? ?? 'Less than 100',
      eventType: map['eventType'] as String? ?? 'Corporate Buffet',
      menuPackage: map['menuPackage'] as String? ?? 'Royal Malabar Feast',
      pricePerPlate: (map['pricePerPlate'] as num?)?.toDouble() ?? 450.0,
      venueAddress: map['venueAddress'] as String? ?? 'Palazhi, Calicut',
      specialInstructions: map['specialInstructions'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '+91 9874563210',
      status: CateringStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
