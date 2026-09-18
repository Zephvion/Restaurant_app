import 'package:flutter/foundation.dart';

/// The five primary top-level features of the Restaurant App.
enum AppMode {
  orderFood,
  takeAway,
  reserveTable,
  catering,
  foodPlanner,
}

/// Metadata and visual properties for each Restaurant App mode.
extension AppModeExt on AppMode {
  String get label {
    switch (this) {
      case AppMode.orderFood:
        return 'Order Food';
      case AppMode.takeAway:
        return 'Take Away';
      case AppMode.reserveTable:
        return 'Reserve Table';
      case AppMode.catering:
        return 'Catering';
      case AppMode.foodPlanner:
        return 'Food Planner';
    }
  }

  String get badge {
    switch (this) {
      case AppMode.orderFood:
        return 'DELIVERY';
      case AppMode.takeAway:
        return 'PICKUP';
      case AppMode.reserveTable:
        return 'BOOKING';
      case AppMode.catering:
        return 'EVENTS';
      case AppMode.foodPlanner:
        return 'WEEKLY';
    }
  }
}

/// Singleton [ChangeNotifier] for managing top-level mode switching in the Restaurant App.
class AppModeController extends ChangeNotifier {
  AppModeController._();
  static final AppModeController instance = AppModeController._();

  AppMode _mode = AppMode.orderFood;

  AppMode get mode => _mode;

  bool get isOrderFood => _mode == AppMode.orderFood;
  bool get isTakeAway => _mode == AppMode.takeAway;
  bool get isReserveTable => _mode == AppMode.reserveTable;
  bool get isCatering => _mode == AppMode.catering;
  bool get isFoodPlanner => _mode == AppMode.foodPlanner;

  void setMode(AppMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }
}
