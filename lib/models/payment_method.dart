import 'package:flutter/foundation.dart';

/// The category of a saved payment method — drives which section it appears
/// under on the payment screens.
enum PaymentKind { card, upi, wallet, netBanking, cash }

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
}
