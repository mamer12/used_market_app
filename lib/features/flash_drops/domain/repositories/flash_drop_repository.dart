import '../../data/models/flash_drop_model.dart';

abstract class FlashDropRepository {
  Future<List<FlashDropModel>> getActiveFlashDrops();
  Future<void> createFlashDrop({
    required String productId,
    required int discountPct,
    required int slots,
    required DateTime startsAt,
    required DateTime endsAt,
  });
  /// Purchase a flash drop item. Returns the created order ID on success.
  Future<String> purchaseFlashDrop(String flashDropId);
}
