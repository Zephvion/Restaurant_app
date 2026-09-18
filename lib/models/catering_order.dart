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
    this.pickupLocation = 'Paragon Central Catering Hub, Mavoor Road, Kozhikode',
    this.ownerName = 'Chef Rajesh Kumar (Catering Operations Head)',
    this.ownerPhone = '+91 98470 12345',
    required this.date,
    this.timeSlot = 'Lunch (12:00 PM – 3:30 PM)',
    required this.guestRange,
    this.eventType = 'Corporate Buffet',
    this.menuPackage = 'Royal Malabar Feast',
    this.pricePerPlate = 450.0,
    this.totalAmount = 0.0,
    this.venueAddress = 'Palazhi, Calicut',
    this.specialInstructions = '',
    this.contactPhone = '+91 9874563210',
    this.status = CateringStatus.notifiedParagon,
    this.isPaid = false,
    this.paymentTxnId,
    this.paymentMode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'CAT-4578'
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String branchLocation;
  final String pickupLocation;
  final String ownerName;
  final String ownerPhone;
  final DateTime date;
  final String timeSlot;
  final String guestRange; // e.g. '100 - 250 Guests'
  final String eventType; // e.g. 'Wedding Reception'
  final String menuPackage; // e.g. 'Royal Malabar Feast'
  final double pricePerPlate;
  final double totalAmount;
  final String venueAddress;
  final String specialInstructions;
  final String contactPhone;
  CateringStatus status;
  bool isPaid;
  String? paymentTxnId;
  String? paymentMode;
  final DateTime createdAt;

  /// Short human-readable date, e.g. "January 2 , 2023"
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Status badge label
  String get statusLabel {
    switch (status) {
      case CateringStatus.notifiedParagon:
        return 'Request Received - Pending Enquiry & Advance';
      case CateringStatus.call:
        return 'Enquiry Call Scheduled';
      case CateringStatus.bookingConfirmed:
        return 'Booking Confirmed & Advance Verified';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'branchLocation': branchLocation,
        'pickupLocation': pickupLocation,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'guestRange': guestRange,
        'eventType': eventType,
        'menuPackage': menuPackage,
        'pricePerPlate': pricePerPlate,
        'totalAmount': totalAmount,
        'venueAddress': venueAddress,
        'specialInstructions': specialInstructions,
        'contactPhone': contactPhone,
        'status': status.name,
        'isPaid': isPaid,
        'paymentTxnId': paymentTxnId,
        'paymentMode': paymentMode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CateringOrder.fromMap(Map<String, dynamic> map, {String? id}) {
    return CateringOrder(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      restaurantId: map['restaurantId'] as String? ?? 'rest_calicut',
      restaurantName: map['restaurantName'] as String? ?? 'Paragon Restaurant - Calicut',
      branchLocation: map['branchLocation'] as String? ?? 'Mavoor Road, Calicut',
      pickupLocation: map['pickupLocation'] as String? ??
          'Paragon Central Catering Hub, Mavoor Road, Kozhikode',
      ownerName: map['ownerName'] as String? ??
          'Chef Rajesh Kumar (Catering Operations Head)',
      ownerPhone: map['ownerPhone'] as String? ?? '+91 98470 12345',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? 'Lunch (12:00 PM – 3:30 PM)',
      guestRange: map['guestRange'] as String? ?? 'Less than 100',
      eventType: map['eventType'] as String? ?? 'Corporate Buffet',
      menuPackage: map['menuPackage'] as String? ?? 'Royal Malabar Feast',
      pricePerPlate: (map['pricePerPlate'] as num?)?.toDouble() ?? 450.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      venueAddress: map['venueAddress'] as String? ?? 'Palazhi, Calicut',
      specialInstructions: map['specialInstructions'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '+91 9874563210',
      status: CateringStatus.fromString(map['status'] as String?),
      isPaid: (map['isPaid'] as bool?) ?? false,
      paymentTxnId: map['paymentTxnId'] as String?,
      paymentMode: map['paymentMode'] as String?,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
