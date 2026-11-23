
/// Mapbox environment configuration.
///
/// Pass tokens at build time using --dart-define.
/// Never commit real access tokens to source control.
class MapboxConfig {
  MapboxConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String _stagingToken = String.fromEnvironment(
    'MAPBOX_STAGING_TOKEN',
  );

  static const String _productionToken = String.fromEnvironment(
    'MAPBOX_PRODUCTION_TOKEN',
  );

  static String get accessToken {
    switch (environment) {
      case 'staging':
        return _stagingToken;
      case 'production':
        return _productionToken;
      default:
        return '';
    }
  }

  static bool get isConfigured => accessToken.isNotEmpty;

  static bool get isStaging => environment == 'staging';

  static bool get isProduction => environment == 'production';
}
