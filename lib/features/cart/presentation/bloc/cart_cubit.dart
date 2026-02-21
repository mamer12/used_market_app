import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shop/data/models/shop_models.dart';
import '../../data/datasources/cart_remote_data_source.dart';
import '../../data/models/cart_models.dart';

// ── Cart Item ─────────────────────────────────────────────────────────────

/// Local representation of a product in the cart.
/// [cartItemId] is the UUID assigned by the server after the first sync.
class CartItem {
  final ProductModel product;
  final int quantity;

  /// Server-assigned cart item ID (null until first successful sync).
  final String? cartItemId;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.cartItemId,
  });

  CartItem copyWith({int? quantity, String? cartItemId}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        cartItemId: cartItemId ?? this.cartItemId,
      );
}

// ── Saved Product ─────────────────────────────────────────────────────────

/// Local representation of a product in the wishlist.
/// [savedItemId] is the UUID assigned by the server after the first sync.
class SavedProduct {
  final ProductModel product;

  /// Server-assigned saved-item ID (null until first successful sync).
  final String? savedItemId;

  const SavedProduct({required this.product, this.savedItemId});

  SavedProduct copyWith({String? savedItemId}) =>
      SavedProduct(product: product, savedItemId: savedItemId ?? this.savedItemId);
}

// ── State ─────────────────────────────────────────────────────────────────

class CartState {
  final List<CartItem> cartItems;
  final List<SavedProduct> savedItems;

  const CartState({
    this.cartItems = const [],
    this.savedItems = const [],
  });

  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get savedCount => savedItems.length;
  double get cartTotal => cartItems.fold(
        0.0,
        (sum, item) => sum + item.product.price * item.quantity,
      );

  /// Convenience getter — returns just the [ProductModel] list (used by
  /// widgets that don't care about server IDs).
  List<ProductModel> get savedProducts =>
      savedItems.map((s) => s.product).toList();

  CartState copyWith({
    List<CartItem>? cartItems,
    List<SavedProduct>? savedItems,
  }) =>
      CartState(
        cartItems: cartItems ?? this.cartItems,
        savedItems: savedItems ?? this.savedItems,
      );
}

// ── Cubit ─────────────────────────────────────────────────────────────────

/// Manages the shopping cart and wishlist.
///
/// All mutations are applied **optimistically** to local state immediately and
/// then synced to the server in the background.  Failures are silently ignored
/// so the UI remains responsive even when offline.
///
/// [remoteDataSource] is optional — when `null` (e.g. unauthenticated) the
/// cubit works as a pure in-memory store.
class CartCubit extends Cubit<CartState> {
  final CartRemoteDataSource? _remote;

  CartCubit(this._remote) : super(const CartState());

  // ── Cart ────────────────────────────────────────────────────────────

  void addToCart(ProductModel product) {
    final items = List<CartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == product.id);

    if (idx >= 0) {
      // Already in cart — increment quantity
      final newQty = items[idx].quantity + 1;
      items[idx] = items[idx].copyWith(quantity: newQty);
      emit(state.copyWith(cartItems: items));

      // Sync PATCH if server ID is known
      final cartItemId = items[idx].cartItemId;
      if (_remote != null && cartItemId != null) {
        _remote!
            .updateCartItem(
              cartItemId,
              UpdateCartQuantityRequest(quantity: newQty),
            )
            .ignore();
      }
    } else {
      // New cart item — add locally, then POST to server
      items.add(CartItem(product: product));
      emit(state.copyWith(cartItems: items));

      if (_remote != null) {
        _remote!
            .addToCart(
              AddToCartRequest(
                itemType: 'shop_product',
                referenceId: product.id,
                quantity: 1,
              ),
            )
            .then((serverItem) {
          // Patch in the server-assigned ID
          final updated = List<CartItem>.from(state.cartItems);
          final i = updated.indexWhere((c) => c.product.id == product.id);
          if (i >= 0) {
            updated[i] = updated[i].copyWith(cartItemId: serverItem.id);
            emit(state.copyWith(cartItems: updated));
          }
        }).catchError((_) {});
      }
    }
  }

  void removeFromCart(String productId) {
    final found = _cartItemFor(productId);
    emit(state.copyWith(
      cartItems:
          state.cartItems.where((i) => i.product.id != productId).toList(),
    ));
    if (_remote != null && found?.cartItemId != null) {
      _remote!.removeCartItem(found!.cartItemId!).ignore();
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final found = _cartItemFor(productId);
    final items = state.cartItems
        .map((i) =>
            i.product.id == productId ? i.copyWith(quantity: quantity) : i)
        .toList();
    emit(state.copyWith(cartItems: items));

    if (_remote != null && found?.cartItemId != null) {
      _remote!
          .updateCartItem(
            found!.cartItemId!,
            UpdateCartQuantityRequest(quantity: quantity),
          )
          .ignore();
    }
  }

  void clearCart() {
    emit(state.copyWith(cartItems: []));
    _remote?.clearCart().ignore();
  }

  // ── Wishlist ─────────────────────────────────────────────────────────

  void toggleSaved(ProductModel product) {
    final saved = List<SavedProduct>.from(state.savedItems);
    final idx = saved.indexWhere((s) => s.product.id == product.id);

    if (idx >= 0) {
      // Remove from wishlist
      final savedItemId = saved[idx].savedItemId;
      saved.removeAt(idx);
      emit(state.copyWith(savedItems: saved));

      if (_remote != null && savedItemId != null) {
        _remote!.removeSavedItem(savedItemId).ignore();
      }
    } else {
      // Add to wishlist
      saved.insert(0, SavedProduct(product: product));
      emit(state.copyWith(savedItems: saved));

      if (_remote != null) {
        _remote!
            .saveItem(
              AddSavedItemRequest(
                itemType: 'shop_product',
                referenceId: product.id,
              ),
            )
            .then((serverItem) {
          // Patch in the server-assigned ID
          final updated = List<SavedProduct>.from(state.savedItems);
          final i = updated.indexWhere((s) => s.product.id == product.id);
          if (i >= 0) {
            updated[i] = updated[i].copyWith(savedItemId: serverItem.id);
            emit(state.copyWith(savedItems: updated));
          }
        }).catchError((_) {});
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  bool isSaved(String productId) =>
      state.savedItems.any((s) => s.product.id == productId);

  bool isInCart(String productId) =>
      state.cartItems.any((i) => i.product.id == productId);

  CartItem? _cartItemFor(String productId) {
    for (final item in state.cartItems) {
      if (item.product.id == productId) return item;
    }
    return null;
  }
}

