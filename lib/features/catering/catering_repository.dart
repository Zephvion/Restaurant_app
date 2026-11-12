import '../../core/repositories/app_repository.dart';
import '../../models/catering_order.dart';
import '../../state/catering_controller.dart';

/// Data access contract for catering orders.
abstract interface class CateringRepository
    implements AppRepository<CateringOrder> {
  Future<CateringOrder> create({
    required DateTime date,
    required String guestRange,
  });

  Future<void> delete(String id);
}

/// Adapter backed by the existing in-memory catering controller.
class ControllerCateringRepository implements CateringRepository {
  ControllerCateringRepository({
    required CateringController controller,
  }) : _controller = controller;

  final CateringController _controller;

  @override
  Future<List<CateringOrder>> getAll() async => _controller.orders;

  @override
  Future<CateringOrder?> getById(String id) async {
    for (final order in _controller.orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<CateringOrder> create({
    required DateTime date,
    required String guestRange,
  }) async {
    return _controller.placeOrder(
      date: date,
      guestRange: guestRange,
    );
  }

  @override
  Future<void> delete(String id) async {
    _controller.cancelOrder(id);
  }
}