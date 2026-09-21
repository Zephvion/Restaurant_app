enum CashfreeEnvironment {
  sandbox,
  production,
}

class CashfreeConfig {
  CashfreeConfig._();

  /// Cashfree API Environment (default to sandbox for test payments)
  static CashfreeEnvironment environment = CashfreeEnvironment.sandbox;

  /// Cashfree App ID / Client ID.
  /// Replace 'YOUR_CASHFREE_APP_ID' with your App ID from Cashfree Merchant Dashboard
  /// (e.g. TEST10087654...).
  static String appId = 'YOUR_CASHFREE_APP_ID';

  /// Cashfree Secret Key.
  /// Replace 'YOUR_CASHFREE_SECRET_KEY' with your Secret Key from Cashfree Merchant Dashboard.
  static String secretKey = 'YOUR_CASHFREE_SECRET_KEY';

  /// Cashfree API Version (current stable)
  static const String apiVersion = '2023-08-01';

  /// Merchant UPI ID for direct intent and QR routing
  static const String merchantUpiId = 'paragonrestaurant@icici';
  static const String merchantName = 'PARAGON Restaurant';

  /// Base URLs
  static const String sandboxBaseUrl = 'https://sandbox.cashfree.com/pg';
  static const String productionBaseUrl = 'https://api.cashfree.com/pg';

  static String get baseUrl => environment == CashfreeEnvironment.production
      ? productionBaseUrl
      : sandboxBaseUrl;

  static bool get isSandbox => environment == CashfreeEnvironment.sandbox;

  static bool get hasValidCredentials =>
      appId.isNotEmpty &&
      appId != 'YOUR_CASHFREE_APP_ID' &&
      secretKey.isNotEmpty &&
      secretKey != 'YOUR_CASHFREE_SECRET_KEY';
}
