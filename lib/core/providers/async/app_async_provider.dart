import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standard asynchronous state type used across the application.
typedef AppAsyncValue<T> = AsyncValue<T>;

/// Base class for feature-level asynchronous state.
///
/// Extend this class when a feature needs to load data asynchronously.
/// AsyncNotifier provides loading, data, and error states through [state].
abstract class AppAsyncNotifier<T> extends AsyncNotifier<T> {
  /// Override to load the initial feature data.
  @override
  Future<T> build();
}
