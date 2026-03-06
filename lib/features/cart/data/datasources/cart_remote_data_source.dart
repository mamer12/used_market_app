import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/cart_models.dart';

// ── Abstract ──────────────────────────────────────────────────────────────

abstract class CartRemoteDataSource {
  // Cart
  Future<List<CartItemServerModel>> getCart();
  Future<CartItemServerModel> addToCart(AddToCartRequest request);
  Future<CartItemServerModel> updateCartItem(
    String cartItemId,
    UpdateCartQuantityRequest request,
  );
  Future<void> removeCartItem(String cartItemId);
  Future<void> clearCart();

  // Saved Items (Wishlist)
  Future<List<SavedItemServerModel>> getSavedItems();
  Future<SavedItemServerModel> saveItem(AddSavedItemRequest request);
  Future<void> removeSavedItem(String savedItemId);
}

// ── Implementation ────────────────────────────────────────────────────────

@LazySingleton(as: CartRemoteDataSource)
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSourceImpl(this._dio);

  // ── Cart ─────────────────────────────────────────────────────────────

  @override
  Future<List<CartItemServerModel>> getCart() async {
    final response = await _dio.get(ApiConstants.cart);
    final data = response.data as List;
    return data
        .map((e) => CartItemServerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CartItemServerModel> addToCart(AddToCartRequest request) async {
    final response = await _dio.post(ApiConstants.cart, data: request.toJson());
    return CartItemServerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartItemServerModel> updateCartItem(
    String cartItemId,
    UpdateCartQuantityRequest request,
  ) async {
    final response = await _dio.patch(
      '${ApiConstants.cart}/$cartItemId',
      data: request.toJson(),
    );
    return CartItemServerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeCartItem(String cartItemId) async {
    await _dio.delete('${ApiConstants.cart}/$cartItemId');
  }

  @override
  Future<void> clearCart() async {
    await _dio.delete(ApiConstants.cart);
  }

  // ── Saved Items ──────────────────────────────────────────────────────

  @override
  Future<List<SavedItemServerModel>> getSavedItems() async {
    final response = await _dio.get(ApiConstants.savedItems);
    final data = response.data as List;
    return data
        .map((e) => SavedItemServerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SavedItemServerModel> saveItem(AddSavedItemRequest request) async {
    final response = await _dio.post(
      ApiConstants.savedItems,
      data: request.toJson(),
    );
    return SavedItemServerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeSavedItem(String savedItemId) async {
    await _dio.delete('${ApiConstants.savedItems}/$savedItemId');
  }
}
