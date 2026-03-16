import 'package:intl/intl.dart';

class NegotiationModel {
  final String id;
  final String productId;
  final String productTitle;
  final int originalPrice;
  final int offeredPrice;
  final int? counterPrice;
  final String status; // pending|countered|accepted|rejected|expired|paid
  final int round;
  final DateTime? expiresAt;
  final DateTime? lockedUntil;

  const NegotiationModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.originalPrice,
    required this.offeredPrice,
    this.counterPrice,
    required this.status,
    required this.round,
    this.expiresAt,
    this.lockedUntil,
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) =>
      NegotiationModel(
        id: json['id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        productTitle: json['product_title'] as String? ?? '',
        originalPrice: json['original_price'] as int? ?? 0,
        offeredPrice: json['offered_price'] as int? ?? 0,
        counterPrice: json['counter_price'] as int?,
        status: json['status'] as String? ?? 'pending',
        round: json['round'] as int? ?? 1,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        lockedUntil: json['locked_until'] != null
            ? DateTime.parse(json['locked_until'] as String)
            : null,
      );

  String get formattedOfferedPrice =>
      '${NumberFormat('#,###', 'ar_IQ').format(offeredPrice)} د.ع';

  String get formattedOriginalPrice =>
      '${NumberFormat('#,###', 'ar_IQ').format(originalPrice)} د.ع';

  String? get formattedCounterPrice => counterPrice != null
      ? '${NumberFormat('#,###', 'ar_IQ').format(counterPrice)} د.ع'
      : null;
}
