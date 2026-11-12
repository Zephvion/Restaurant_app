import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Central application-level providers.
///
/// Register shared services and repositories here as the
/// application architecture grows.

final appEnvironmentProvider = Provider<String>((ref) {
  return const String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
});

/// Exposes whether the app is running in production.
final isProductionProvider = Provider<bool>((ref) {
  return ref.watch(appEnvironmentProvider) == 'production';
});
