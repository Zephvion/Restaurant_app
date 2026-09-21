import 'package:flutter_dotenv/flutter_dotenv.dart';

enum CashfreeEnvironment {
  sandbox,
  production,
}

class CashfreeConfig {
  CashfreeConfig._();

  static String? _getEnv(String key) {
    if (dotenv.isInitialized) {
      return dotenv.env[key];
    }
    return null;
  }

  /// Cashfree API Environment (default to sandbox for test payments)
  static CashfreeEnvironment get environment {
    final envStr = _getEnv('CASHFREE_ENV')?.toLowerCase().trim();
    if (envStr == 'production' || envStr == 'prod') {
      return CashfreeEnvironment.production;
    }
    return CashfreeEnvironment.sandbox;
  }

  /// Cashfree App ID / Client ID read from .env file
  static String get appId =>
      _getEnv('CASHFREE_APP_ID')?.trim() ?? 'YOUR_CASHFREE_APP_ID';

  /// Cashfree Secret Key read from .env file
  static String get secretKey =>
      _getEnv('CASHFREE_SECRET_KEY')?.trim() ?? 'YOUR_CASHFREE_SECRET_KEY';

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
