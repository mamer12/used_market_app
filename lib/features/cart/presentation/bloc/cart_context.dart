/// Cart context / Mini-App isolation.
///
/// Each Mini-App that has a shopping cart creates its own [ScopedCartCubit]
/// with the matching [CartAppContext]. This keeps item lists, counts, and
/// backend calls fully isolated between Matajir and Balla (and any future
/// mini-app that needs a cart).
library;

import '../../../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../../../features/cart/data/models/cart_models.dart';
import '../../../../features/shop/data/models/shop_models.dart';
import 'cart_cubit.dart';

// ── Context enum ─────────────────────────────────────────────────────────────

/// Which Mini-App "owns" the cart instance.
enum CartAppContext { matajir, balla }

extension CartAppContextExt on CartAppContext {
  /// The string sent to the backend as `app_context`.
  String get apiValue => switch (this) {
    CartAppContext.matajir => 'matajir',
    CartAppContext.balla => 'balla',
  };

  /// The `item_type` prefix for API payloads.
  String get itemTypePrefix => switch (this) {
    CartAppContext.matajir => 'matajir_product',
    CartAppContext.balla => 'balla_product',
  };

  /// Display label shown in the cart page header (fallback — prefer l10n keys).
  String get displayName => switch (this) {
    CartAppContext.matajir => 'سلة المتاجر',
    CartAppContext.balla => 'سلة البالة',
  };
}

// ── Scoped Cubit ─────────────────────────────────────────────────────────────

/// A [CartCubit] that is scoped to a single Mini-App.
///
/// Creates isolated cart state per Mini-App screen. Compose it via
/// `BlocProvider(create: (_) => ScopedCartCubit(CartAppContext.matajir, remote))`
/// at the Mini-App root so that child widgets can read it with
/// `context.read<ScopedCartCubit>()`.
///
/// Key behaviours:
/// - **Optimistic local update** — state emitted immediately for responsive UI.
/// - **app_context tagging** — every backend POST includes `app_context` so the
///   server routes the item to the correct commerce pipeline.
/// - **Conflict detection** — if the cart already contains items from a
///   different `app_context`, [CartStatus.conflict] is emitted instead of
///   silently mixing items.
class ScopedCartCubit extends CartCubit {
  final CartAppContext appContext;

  ScopedCartCubit(this.appContext, CartRemoteDataSource? remote)
    : super(remote);

  /// Adds [product] to this Mini-App's isolated cart.
  ///
  /// If the cart already contains items from a different [CartAppContext],
  /// emits [CartState] with [CartStatus.conflict] and stores the pending
  /// product so the conflict UI can offer to clear or keep the existing cart.
  @override
  void addToCart(ProductModel product) {
    // --- Conflict detection ---
    if (state.cartItems.isNotEmpty) {
      final existingContext = state.cartItems.first.appContext;
      if (existingContext != null && existingContext != appContext.apiValue) {
        // Cross-context conflict — emit conflict state instead of adding
        emit(
          state.copyWith(
            cartStatus: CartStatus.conflict,
            conflictData: CartConflictData(
              pendingContextApiValue: appContext.apiValue,
              pendingProduct: product,
            ),
          ),
        );
        return;
      }
    }

    // --- Normal add —-
    final items = List<CartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == product.id);

    if (idx >= 0) {
      // Already in cart — increment quantity
      final newQty = items[idx].quantity + 1;
      items[idx] = items[idx].copyWith(quantity: newQty);
      emit(state.copyWith(cartItems: items, cartStatus: CartStatus.idle));

      final cartItemId = items[idx].cartItemId;
      if (remote != null && cartItemId != null) {
        remote!
            .updateCartItem(
              cartItemId,
              UpdateCartQuantityRequest(quantity: newQty),
            )
            .ignore();
      }
    } else {
      // New item — add locally with app_context tag, then POST to server
      items.add(CartItem(product: product, appContext: appContext.apiValue));
      emit(state.copyWith(cartItems: items, cartStatus: CartStatus.idle));

      remote
          ?.addToCart(
            AddToCartRequest(
              itemType: appContext.itemTypePrefix,
              referenceId: product.id,
              quantity: 1,
              appContext: appContext.apiValue,
            ),
          )
          .then((serverItem) {
            final updated = List<CartItem>.from(state.cartItems);
            final i = updated.indexWhere((c) => c.product.id == product.id);
            if (i >= 0) {
              updated[i] = updated[i].copyWith(cartItemId: serverItem.id);
              emit(state.copyWith(cartItems: updated));
            }
          })
          .catchError((_) {});
    }
  }

  /// Resolves a cart conflict by clearing the existing cart and adding the
  /// pending product. Called from [CartConflictSheet] "Clear & Add" button.
  void resolveConflictByClear() {
    final pending = state.conflictData?.pendingProduct;
    clearCart();
    if (pending != null) addToCart(pending);
  }

  /// Resolves a cart conflict by discarding the pending product.
  /// Called from [CartConflictSheet] "Keep" button.
  void resolveConflictByKeeping() {
    emit(state.copyWith(cartStatus: CartStatus.idle, clearConflict: true));
  }
}
