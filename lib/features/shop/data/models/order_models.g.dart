// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    _ShippingAddress(
      city: json['city'] as String,
      district: json['district'] as String,
      street: json['street'] as String,
      building: json['building'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$ShippingAddressToJson(_ShippingAddress instance) =>
    <String, dynamic>{
      'city': instance.city,
      'district': instance.district,
      'street': instance.street,
      'building': instance.building,
      'phone': instance.phone,
    };

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  buyerId: json['buyer_id'] as String,
  sellerId: json['seller_id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  totalPrice: (json['total_price'] as num).toDouble(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  shippingAddress: ShippingAddress.fromJson(
    json['shipping_address'] as Map<String, dynamic>,
  ),
  fulfillmentType: json['fulfillment_type'] as String,
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'buyer_id': instance.buyerId,
      'seller_id': instance.sellerId,
      'quantity': instance.quantity,
      'total_price': instance.totalPrice,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'shipping_address': instance.shippingAddress,
      'fulfillment_type': instance.fulfillmentType,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pendingPayment: 'PENDING_PAYMENT',
  OrderStatus.paidToEscrow: 'PAID_TO_ESCROW',
  OrderStatus.shipped: 'SHIPPED',
  OrderStatus.delivered: 'DELIVERED',
  OrderStatus.fundsReleased: 'FUNDS_RELEASED',
  OrderStatus.pendingCODFulfillment: 'PENDING_COD_FULFILLMENT',
  OrderStatus.deliveredAndCashCollected: 'DELIVERED_AND_CASH_COLLECTED',
};

_BuyProductRequest _$BuyProductRequestFromJson(Map<String, dynamic> json) =>
    _BuyProductRequest(
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      shippingAddress: ShippingAddress.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      ),
      fulfillmentType: json['fulfillment_type'] as String,
      appContext: json['app_context'] as String?,
    );

Map<String, dynamic> _$BuyProductRequestToJson(_BuyProductRequest instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'shipping_address': instance.shippingAddress,
      'fulfillment_type': instance.fulfillmentType,
      'app_context': instance.appContext,
    };

_UpdateOrderStatusRequest _$UpdateOrderStatusRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateOrderStatusRequest(
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
);

Map<String, dynamic> _$UpdateOrderStatusRequestToJson(
  _UpdateOrderStatusRequest instance,
) => <String, dynamic>{'status': _$OrderStatusEnumMap[instance.status]!};
