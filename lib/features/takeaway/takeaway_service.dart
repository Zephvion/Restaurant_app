import '../../models/restaurant.dart';
import '../../models/takeaway_order.dart';
import 'takeaway_repository.dart';

class TakeawayService {
  TakeawayService({required TakeawayRepository repository})
      : _repository = repository;

  final TakeawayRepository _repository;

  Future<List<TakeawayOrder>> getOrders() {
    return _repository.getAll();
  }

  Future<TakeawayOrder?> getOrder(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Takeaway order ID cannot be empty.');
    }

    return _repository.getById(id);
  }

  Future<TakeawayOrder> placeOrder({Restaurant? restaurant}) async {
    return _repository.placeOrder(restaurant: restaurant);
  }
}