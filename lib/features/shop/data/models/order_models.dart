import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

enum OrderStatus {
  @JsonValue('PENDING_PAYMENT')
  pendingPayment,
  @JsonValue('PAID_TO_ESCROW')
  paidToEscrow,
  @JsonValue('SHIPPED')
  shipped,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('FUNDS_RELEASED')
  fundsReleased,
}

@freezed
abstract class ShippingAddress with _$ShippingAddress {
  const factory ShippingAddress({
    required String city,
    required String street,
  }) = _ShippingAddress;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);
}

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'buyer_id') required String buyerId,
    @JsonKey(name: 'seller_id') required String sellerId,
    required int quantity,
    @JsonKey(name: 'total_price') required double totalPrice,
    required OrderStatus status,
    @JsonKey(name: 'shipping_address') required ShippingAddress shippingAddress,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
abstract class BuyProductRequest with _$BuyProductRequest {
  const factory BuyProductRequest({
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'shipping_address') required ShippingAddress shippingAddress,
  }) = _BuyProductRequest;

  factory BuyProductRequest.fromJson(Map<String, dynamic> json) =>
      _$BuyProductRequestFromJson(json);
}

@freezed
abstract class UpdateOrderStatusRequest with _$UpdateOrderStatusRequest {
  const factory UpdateOrderStatusRequest({required OrderStatus status}) =
      _UpdateOrderStatusRequest;

  factory UpdateOrderStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStatusRequestFromJson(json);
}
