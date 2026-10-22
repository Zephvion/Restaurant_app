import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Centralized service managing Over-The-Air (OTA) Code Push updates via Shorebird.
///
/// Features:
/// - Checks for updates automatically in the background on app startup.
/// - Downloads patches seamlessly without interrupting the user.
/// - The downloaded patch takes effect automatically on the next app restart.
/// - Provides explicit check method for Settings / Account screens.
class CodePushService {
  CodePushService._();
  static final CodePushService instance = CodePushService._();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Whether Shorebird code push is active in the current running environment.
  /// Returns `false` in debug builds, simulators, or web.
  bool get isAvailable {
    try {
      return _updater.isAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Silently checks for updates and prepares the patch in the background.
  Future<void> checkForUpdatesInBackground() async {
    if (!isAvailable) {
      debugPrint('ℹ️ [Shorebird] Code Push is not active in this environment (active on Shorebird release builds).');
      return;
    }

    try {
      debugPrint('🔍 [Shorebird] Checking for OTA updates...');
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        debugPrint('🚀 [Shorebird] New OTA patch available! Downloading in background...');
        await _updater.update();
        debugPrint('✅ [Shorebird] Update downloaded successfully! Will take effect on next launch.');
      } else if (status == UpdateStatus.restartRequired) {
        debugPrint('🔄 [Shorebird] An update is downloaded and ready to apply on next launch.');
      } else {
        debugPrint('✨ [Shorebird] App is up to date.');
      }
    } catch (e) {
      debugPrint('⚠️ [Shorebird] Update check note: $e');
    }
  }

  /// Performs an explicit manual update check and returns a friendly status message.
  Future<String> checkForUpdatesExplicitly() async {
    if (!isAvailable) {
      return 'Over-the-air updates are enabled for Shorebird release installations.';
    }

    try {
      final status = await _updater.checkForUpdate();
      switch (status) {
        case UpdateStatus.outdated:
          await _updater.update();
          return 'New update downloaded! Restart the app to apply the latest changes.';
        case UpdateStatus.upToDate:
          return 'You are on the latest version of PARAGON.';
        case UpdateStatus.restartRequired:
          return 'An update is already ready! Please close and reopen the app.';
        case UpdateStatus.unavailable:
          return 'Update service is currently unavailable. Please check your internet connection.';
      }
    } catch (e) {
      return 'Unable to check for updates: $e';
    }
  }
}

