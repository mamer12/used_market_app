import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';

/// Repository for filing order disputes.
///
/// Usage:
/// ```dart
/// final repo = getIt<DisputeRepository>();
/// await repo.createDispute(
///   orderId: '123',
///   reason: 'item_not_received',
///   description: 'لم يصلني الطلب رغم مرور أسبوعين',
///   evidenceUrls: ['https://...'],
/// );
/// ```
@LazySingleton()
class DisputeRepository {
  final Dio _dio;

  DisputeRepository(this._dio);

  /// Submits a dispute for [orderId].
  ///
  /// [reason]       — one of: item_not_received, item_not_as_described,
  ///                  item_damaged, other
  /// [description]  — required, min 20 chars
  /// [evidenceUrls] — optional, up to 3 pre-uploaded media URLs
  Future<void> createDispute({
    required String orderId,
    required String reason,
    required String description,
    List<String> evidenceUrls = const [],
  }) async {
    await _dio.post(
      ApiConstants.orderDispute(orderId),
      data: {
        'reason': reason,
        'description': description,
        'evidence_urls': evidenceUrls,
      },
    );
  }
}
