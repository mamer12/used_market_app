import 'package:injectable/injectable.dart';

import '../../domain/repositories/flash_drop_repository.dart';
import '../datasources/flash_drop_remote_data_source.dart';
import '../models/flash_drop_model.dart';

@LazySingleton(as: FlashDropRepository)
class FlashDropRepositoryImpl implements FlashDropRepository {
  final FlashDropRemoteDataSource _remoteDataSource;

  FlashDropRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FlashDropModel>> getActiveFlashDrops() =>
      _remoteDataSource.getActiveFlashDrops();

  @override
  Future<void> createFlashDrop({
    required String productId,
    required int discountPct,
    required int slots,
    required DateTime startsAt,
    required DateTime endsAt,
  }) =>
      _remoteDataSource.createFlashDrop(
        productId: productId,
        discountPct: discountPct,
        slots: slots,
        startsAt: startsAt,
        endsAt: endsAt,
      );
}
