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
  final bool isNewUser;

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
    this.isNewUser = false,
  });

  /// Evaluates whether this profile has real personal information (name, real email)
  /// or requires completion by the newly verified phone user.
  bool get isProfileComplete {
    final name = displayName.trim();
    if (name.isEmpty || name == 'User' || name == 'Valued Guest') {
      return false;
    }
    final em = email.trim();
    if (em.isEmpty || (em.endsWith('@paragon.com') && em.contains('user.'))) {
      return false;
    }
    return true;
  }

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
    bool? isNewUser,
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
      isNewUser: isNewUser ?? this.isNewUser,
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
      'savedAddresses': savedAddresses.map((a) => a.toMap()).toList(),
      'savedPaymentMethods': savedPaymentMethods.map((p) => p.toMap()).toList(),
      'orderHistory': orderHistory,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isNewUser': isNewUser,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? uid}) {
    final rawAddresses = map['savedAddresses'] as List<dynamic>?;
    final parsedAddresses = rawAddresses != null
        ? rawAddresses
            .where((e) => e is Map)
            .map((e) => Address.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
        : const <Address>[];

    final rawPaymentMethods = map['savedPaymentMethods'] as List<dynamic>?;
    final parsedPaymentMethods = rawPaymentMethods != null
        ? rawPaymentMethods
            .where((e) => e is Map)
            .map((e) => PaymentMethod.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
        : const <PaymentMethod>[];

    return UserProfile(
      uid: uid ?? (map['uid'] as String? ?? ''),
      displayName: map['displayName'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      defaultDeliveryArea:
          map['defaultDeliveryArea'] as String? ?? 'Palazhi , Calicut',
      savedAddresses: parsedAddresses,
      savedPaymentMethods: parsedPaymentMethods,
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
      isNewUser: map['isNewUser'] == true,
    );
  }
}

