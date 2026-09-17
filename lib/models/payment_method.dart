import 'package:flutter/foundation.dart';

/// The category of a saved payment method — drives which section it appears
/// under on the payment screens.
enum PaymentKind {
  card,
  upi,
  wallet,
  netBanking,
  cash;

  static PaymentKind fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'upi':
        return PaymentKind.upi;
      case 'wallet':
        return PaymentKind.wallet;
      case 'netbanking':
      case 'net_banking':
        return PaymentKind.netBanking;
      case 'cash':
        return PaymentKind.cash;
      case 'card':
      default:
        return PaymentKind.card;
    }
  }
}

/// A saved / selectable payment method (card, UPI id, wallet, COD…).
@immutable
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle,
    this.assetKind,
  });

  final String id;
  final String title;

  /// Optional secondary line (e.g. the bank name under a card).
  final String? subtitle;

  final PaymentKind kind;

  /// A small tag used to pick which mini brand-mark to paint
  /// (e.g. 'mastercard', 'visa', 'gpay', 'phonepe', 'upi', 'cod').
  final String? assetKind;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'kind': kind.name,
        'assetKind': assetKind,
      };

  factory PaymentMethod.fromMap(Map<String, dynamic> map, {String? id}) {
    return PaymentMethod(
      id: id ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      kind: PaymentKind.fromString(map['kind'] as String?),
      assetKind: map['assetKind'] as String?,
    );
  }
}
