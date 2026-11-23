import '../../models/catering_order.dart';
import 'catering_repository.dart';

/// Handles catering use cases independently of the data source.
class CateringService {
  CateringService({
    required CateringRepository repository,
  }) : _repository = repository;

  final CateringRepository _repository;

  Future<List<CateringOrder>> getOrders() {
    return _repository.getAll();
  }

  Future<CateringOrder?> getOrder(String id) {
    return _repository.getById(id);
  }

  Future<CateringOrder> placeOrder({
    required DateTime date,
    required String guestRange,
  }) async {
    if (guestRange.trim().isEmpty) {
      throw ArgumentError('Guest range cannot be empty.');
    }

    return _repository.create(
      date: date,
      guestRange: guestRange,
    );
  }

  Future<void> cancelOrder(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Catering order ID cannot be empty.');
    }

    await _repository.delete(id);
  }
}