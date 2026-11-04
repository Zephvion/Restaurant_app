import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/catering/catering_repository.dart';
import '../features/catering/catering_service.dart';
import '../models/catering_order.dart';
import 'catering_controller.dart';

/// Provides the existing app-wide catering controller.
final cateringControllerProvider =
    ChangeNotifierProvider<CateringController>((ref) {
  return CateringController.instance;
});

/// Injects the catering repository.
final cateringRepositoryProvider = Provider<CateringRepository>((ref) {
  final controller = ref.watch(cateringControllerProvider);

  return ControllerCateringRepository(controller: controller);
});

/// Injects the catering service.
final cateringServiceProvider = Provider<CateringService>((ref) {
  final repository = ref.watch(cateringRepositoryProvider);

  return CateringService(repository: repository);
});

/// Loads catering orders through the service/repository boundary.
final cateringOrdersAsyncProvider =
    FutureProvider<List<CateringOrder>>((ref) {
  return ref.watch(cateringServiceProvider).getOrders();
});

/// Loads one catering order through the service/repository boundary.
final cateringOrderByIdProvider =
    FutureProvider.family<CateringOrder?, String>((ref, id) {
  return ref.watch(cateringServiceProvider).getOrder(id);
});

/// Legacy synchronous provider retained for screens not yet migrated.
final cateringOrdersProvider = Provider<List<CateringOrder>>((ref) {
  return ref.watch(cateringControllerProvider).orders;
});

/// Legacy synchronous empty-state provider.
final hasNoCateringOrdersProvider = Provider<bool>((ref) {
  return ref.watch(cateringOrdersProvider).isEmpty;
});