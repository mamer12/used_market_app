import 'package:intl/intl.dart';

class GroupBuyModel {
  final String id;
  final String productId;
  final String productTitle;
  final String? productImageUrl;
  final int targetCount;
  final int currentCount;
  final int discountPct;
  final String status; // open|completed|expired|cancelled
  final DateTime expiresAt;

  const GroupBuyModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    this.productImageUrl,
    required this.targetCount,
    required this.currentCount,
    required this.discountPct,
    required this.status,
    required this.expiresAt,
  });

  factory GroupBuyModel.fromJson(Map<String, dynamic> json) => GroupBuyModel(
        id: json['id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        productTitle: json['product_title'] as String? ?? '',
        productImageUrl: json['product_image_url'] as String?,
        targetCount: json['target_count'] as int? ?? 0,
        currentCount: json['current_count'] as int? ?? 0,
        discountPct: json['discount_pct'] as int? ?? 0,
        status: json['status'] as String? ?? 'open',
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : DateTime.now().add(const Duration(days: 1)),
      );

  double get progress =>
      targetCount > 0 ? currentCount / targetCount : 0.0;

  bool get isCompleted => status == 'completed';

  String get arabicCurrentCount =>
      NumberFormat('#,###', 'ar_IQ').format(currentCount);

  String get arabicTargetCount =>
      NumberFormat('#,###', 'ar_IQ').format(targetCount);
}
