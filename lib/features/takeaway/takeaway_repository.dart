import '../../core/repositories/app_repository.dart';
import '../../models/restaurant.dart';
import '../../models/takeaway_order.dart';
import '../../state/takeaway_controller.dart';

abstract interface class TakeawayRepository
    implements AppRepository<TakeawayOrder> {
  Future<TakeawayOrder> placeOrder({Restaurant? restaurant});
}

class ControllerTakeawayRepository implements TakeawayRepository {
  ControllerTakeawayRepository({
    required TakeawayController controller,
  }) : _controller = controller;

  final TakeawayController _controller;

  @override
  Future<List<TakeawayOrder>> getAll() async => _controller.orders;

  @override
  Future<TakeawayOrder?> getById(String id) async {
    for (final order in _controller.orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<TakeawayOrder> placeOrder({Restaurant? restaurant}) async {
    return _controller.placeOrder(restaurantOverride: restaurant);
  }
}