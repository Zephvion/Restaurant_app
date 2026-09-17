import 'address.dart';
import 'payment_method.dart';

/// User profile model for Firebase backend and session management.
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String photoUrl;
  final String defaultDeliveryArea;
  final List<Address> savedAddresses;
  final List<PaymentMethod> savedPaymentMethods;
  final List<String> orderHistory;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    this.photoUrl = '',
    this.defaultDeliveryArea = 'Palazhi , Calicut',
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
    this.orderHistory = const [],
    this.createdAt,
    this.lastLoginAt,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    String? defaultDeliveryArea,
    List<Address>? savedAddresses,
    List<PaymentMethod>? savedPaymentMethods,
    List<String>? orderHistory,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      defaultDeliveryArea: defaultDeliveryArea ?? this.defaultDeliveryArea,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
      orderHistory: orderHistory ?? this.orderHistory,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'defaultDeliveryArea': defaultDeliveryArea,
      'orderHistory': orderHistory,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserProfile(
      uid: uid ?? (map['uid'] as String? ?? ''),
      displayName: map['displayName'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      defaultDeliveryArea:
          map['defaultDeliveryArea'] as String? ?? 'Palazhi , Calicut',
      orderHistory: (map['orderHistory'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
    );
  }
}

