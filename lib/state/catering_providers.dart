import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catering_order.dart';
import 'catering_controller.dart';

/// Provides the existing app-wide catering controller.
final cateringControllerProvider =
    ChangeNotifierProvider<CateringController>((ref) {
  return CateringController.instance;
});

/// Provides the current catering orders.
final cateringOrdersProvider = Provider<List<CateringOrder>>((ref) {
  return ref.watch(cateringControllerProvider).orders;
});

/// Provides whether the user has no catering orders.
final hasNoCateringOrdersProvider = Provider<bool>((ref) {
  return ref.watch(cateringControllerProvider).hasNoOrders;
});
