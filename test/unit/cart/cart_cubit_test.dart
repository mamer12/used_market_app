// test/unit/cart/cart_cubit_test.dart
//
// Unit tests for CartCubit (the base class used by MatajirCartCubit &
// BallaCartCubit).
//
// Covers:
//   1. addToCart — new item added
//   2. addToCart — existing item increments quantity
//   3. removeFromCart — item removed
//   4. updateQuantity — zero/negative calls removeFromCart
//   5. clearCart — empties items
//   6. toggleSaved — adds to wishlist
//   7. toggleSaved — removes from wishlist (toggle)
//   8. isInCart / isSaved helpers
//   9. cartTotal calculation
//  10. Offline mode (no remote) — mutations still work locally
//  11. cartCount — sum of all item quantities
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:luqta/features/cart/data/models/cart_models.dart';
import 'package:luqta/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:luqta/features/shop/data/models/shop_models.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

class FakeAddToCartRequest extends Fake implements AddToCartRequest {}

class FakeAddSavedItemRequest extends Fake implements AddSavedItemRequest {}

class FakeUpdateCartQuantityRequest extends Fake
    implements UpdateCartQuantityRequest {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
ProductModel _product({String id = 'prod-1', double price = 25_000}) =>
    ProductModel(
      id: id,
      shopId: 'shop-1',
      name: 'منتج تجريبي',
      price: price,
    );

/// Fake server response returned by the remote after POST /cart
CartItemServerModel _serverCartItem({String id = 'ci-1'}) =>
    CartItemServerModel(
      id: id,
      userId: 'user-001',
      itemType: 'shop_product',
      referenceId: 'prod-1',
      quantity: 1,
    );

/// Fake server response returned by the remote after POST /saved-items
SavedItemServerModel _serverSavedItem({String id = 'si-1'}) =>
    SavedItemServerModel(
      id: id,
      userId: 'user-001',
      itemType: 'shop_product',
      referenceId: 'prod-1',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAddToCartRequest());
    registerFallbackValue(FakeAddSavedItemRequest());
    registerFallbackValue(FakeUpdateCartQuantityRequest());
  });

  late MockCartRemoteDataSource remote;

  setUp(() {
    remote = MockCartRemoteDataSource();

    // Default remote stubs — CartCubit fires-and-forgets these
    when(() => remote.addToCart(any()))
        .thenAnswer((_) async => _serverCartItem());
    when(() => remote.updateCartItem(any(), any())).thenAnswer((_) async =>
        _serverCartItem()); // returns CartItemServerModel not void
    when(() => remote.removeCartItem(any())).thenAnswer((_) async {});
    when(() => remote.clearCart()).thenAnswer((_) async {});
    when(() => remote.saveItem(any()))
        .thenAnswer((_) async => _serverSavedItem());
    when(() => remote.removeSavedItem(any())).thenAnswer((_) async {});
  });

  CartCubit buildCubit({bool withRemote = true}) =>
      CartCubit(withRemote ? remote : null);

  // ── 1. addToCart — new item ────────────────────────────────────────────────

  blocTest<CartCubit, CartState>(
    'addToCart adds a new product with quantity 1',
    build: buildCubit,
    act: (cubit) => cubit.addToCart(_product()),
    // CartCubit emits optimistically (1st), then again when the server returns
    // the cart-item ID and patches it in (2nd). Both states should show qty 1.
    expect: () => [
      predicate<CartState>(
        (s) => s.cartItems.length == 1 && s.cartItems[0].quantity == 1,
        'one item, qty 1 (optimistic)',
      ),
      predicate<CartState>(
        (s) => s.cartItems.length == 1 && s.cartItems[0].quantity == 1,
        'one item, qty 1 (server ID patched in)',
      ),
    ],
  );

  // ── 2. addToCart — duplicate increments quantity ──────────────────────────

  blocTest<CartCubit, CartState>(
    'addToCart same product a second time increments quantity to 2',
    build: buildCubit,
    seed: () => CartState(
      cartItems: [CartItem(product: _product(), quantity: 1)],
    ),
    act: (cubit) => cubit.addToCart(_product()),
    expect: () => [
      predicate<CartState>(
        (s) => s.cartItems.length == 1 && s.cartItems[0].quantity == 2,
        'same item, qty 2',
      ),
    ],
  );

  // ── 3. removeFromCart ─────────────────────────────────────────────────────

  blocTest<CartCubit, CartState>(
    'removeFromCart removes the product from state',
    build: buildCubit,
    seed: () => CartState(
      cartItems: [CartItem(product: _product(), quantity: 2)],
    ),
    act: (cubit) => cubit.removeFromCart('prod-1'),
    expect: () => [
      predicate<CartState>(
        (s) => s.cartItems.isEmpty,
        'cart empty after remove',
      ),
    ],
  );

  // ── 4. updateQuantity — zero / negative → remove ──────────────────────────

  blocTest<CartCubit, CartState>(
    'updateQuantity with 0 removes the item',
    build: buildCubit,
    seed: () => CartState(
      cartItems: [CartItem(product: _product(), quantity: 3)],
    ),
    act: (cubit) => cubit.updateQuantity('prod-1', 0),
    expect: () => [
      predicate<CartState>((s) => s.cartItems.isEmpty, 'removed via qty 0'),
    ],
  );

  blocTest<CartCubit, CartState>(
    'updateQuantity with -1 also removes the item',
    build: buildCubit,
    seed: () => CartState(
      cartItems: [CartItem(product: _product(), quantity: 1)],
    ),
    act: (cubit) => cubit.updateQuantity('prod-1', -1),
    expect: () => [
      predicate<CartState>((s) => s.cartItems.isEmpty, 'removed via qty -1'),
    ],
  );

  // ── 5. clearCart ──────────────────────────────────────────────────────────

  blocTest<CartCubit, CartState>(
    'clearCart empties the cart',
    build: buildCubit,
    seed: () => CartState(
      cartItems: [
        CartItem(product: _product(id: 'p1')),
        CartItem(product: _product(id: 'p2')),
      ],
    ),
    act: (cubit) => cubit.clearCart(),
    expect: () => [
      predicate<CartState>((s) => s.cartItems.isEmpty, 'all items cleared'),
    ],
  );

  // ── 6. toggleSaved — add to wishlist ──────────────────────────────────────

  blocTest<CartCubit, CartState>(
    'toggleSaved adds product to savedItems when not already saved',
    build: buildCubit,
    act: (cubit) => cubit.toggleSaved(_product()),
    // Same pattern as addToCart: optimistic emit + server-ID patch-in emit.
    expect: () => [
      predicate<CartState>((s) => s.savedItems.length == 1, 'saved (optimistic)'),
      predicate<CartState>(
        (s) => s.savedItems.length == 1,
        'saved (server ID patched in)',
      ),
    ],
  );

  // ── 7. toggleSaved — remove from wishlist ─────────────────────────────────

  blocTest<CartCubit, CartState>(
    'toggleSaved removes product when already saved',
    build: buildCubit,
    seed: () => CartState(
      savedItems: [
        SavedProduct(product: _product(), savedItemId: 'si-1'),
      ],
    ),
    act: (cubit) => cubit.toggleSaved(_product()),
    expect: () => [
      predicate<CartState>(
        (s) => s.savedItems.isEmpty,
        'save toggled off',
      ),
    ],
    verify: (_) {
      verify(() => remote.removeSavedItem('si-1')).called(1);
    },
  );

  // ── 8. isInCart / isSaved helpers ─────────────────────────────────────────

  test('isInCart returns true after addToCart', () {
    final cubit = buildCubit();
    cubit.addToCart(_product());
    expect(cubit.isInCart('prod-1'), isTrue);
    expect(cubit.isInCart('does-not-exist'), isFalse);
    cubit.close();
  });

  test('isSaved returns true after toggleSaved', () {
    final cubit = buildCubit();
    cubit.toggleSaved(_product());
    expect(cubit.isSaved('prod-1'), isTrue);
    cubit.close();
  });

  // ── 9. cartTotal ──────────────────────────────────────────────────────────

  test('cartTotal reflects price × quantity summed across items', () {
    final cubit = buildCubit();
    cubit.addToCart(_product(id: 'p1', price: 10_000));
    cubit.addToCart(_product(id: 'p2', price: 20_000));
    cubit.updateQuantity('p1', 3);
    // total = 3 × 10_000 + 1 × 20_000 = 50_000
    expect(cubit.state.cartTotal, 50_000.0);
    cubit.close();
  });

  // ── 10. Offline mode ──────────────────────────────────────────────────────

  blocTest<CartCubit, CartState>(
    'addToCart works without a remote (offline mode)',
    build: () => buildCubit(withRemote: false),
    act: (cubit) => cubit.addToCart(_product()),
    expect: () => [
      predicate<CartState>(
        (s) => s.cartItems.length == 1,
        'item added locally without remote',
      ),
    ],
    verify: (_) {
      verifyNever(() => remote.addToCart(any()));
    },
  );

  // ── 11. cartCount ─────────────────────────────────────────────────────────

  test('cartCount returns sum of all item quantities', () {
    final cubit = buildCubit();
    cubit.addToCart(_product(id: 'p1'));
    cubit.addToCart(_product(id: 'p1')); // qty 2
    cubit.addToCart(_product(id: 'p2')); // qty 1
    // 2 + 1 = 3
    expect(cubit.state.cartCount, 3);
    cubit.close();
  });

  // ── 12. Cart isolation (two independent cubits) ───────────────────────────

  test('Two CartCubit instances are isolated — no shared state', () {
    final cubitA = buildCubit();
    final cubitB = buildCubit();

    cubitA.addToCart(_product(id: 'prod-A1'));
    cubitB.addToCart(_product(id: 'prod-B1'));
    cubitB.addToCart(_product(id: 'prod-B2'));

    expect(cubitA.state.cartItems.length, 1);
    expect(cubitB.state.cartItems.length, 2);

    // Each cubit's items must belong only to its own context
    expect(cubitA.isInCart('prod-B1'), isFalse);
    expect(cubitB.isInCart('prod-A1'), isFalse);

    cubitA.close();
    cubitB.close();
  });
}
