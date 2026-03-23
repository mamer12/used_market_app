// test/unit/shop/order_cubit_test.dart
//
// Unit tests for OrderCubit.
// Covers: buyProduct success/error, COD flow, loadOrders success/error.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/shop/data/models/order_models.dart';
import 'package:luqta/features/shop/domain/repositories/order_repository.dart';
import 'package:luqta/features/shop/presentation/bloc/order_cubit.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockOrderRepository extends Mock implements OrderRepository {}

class FakeBuyProductRequest extends Fake implements BuyProductRequest {}

class FakeUpdateOrderStatusRequest extends Fake
    implements UpdateOrderStatusRequest {}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _kAddress = ShippingAddress(
  city: 'Baghdad',
  district: 'Karrada',
  street: 'Main St',
  building: '12',
  phone: '+9647501234567',
);

OrderModel _fakeOrder({
  String id = 'ord-1',
  OrderStatus status = OrderStatus.pendingPayment,
}) =>
    OrderModel(
      id: id,
      productId: 'prod-1',
      buyerId: 'buyer-1',
      sellerId: 'seller-1',
      quantity: 1,
      totalPrice: 50000,
      status: status,
      shippingAddress: _kAddress,
      fulfillmentType: 'escrow',
    );

BuyProductRequest _fakeBuyRequest() => const BuyProductRequest(
      productId: 'prod-1',
      quantity: 1,
      shippingAddress: _kAddress,
      fulfillmentType: 'escrow',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuyProductRequest());
    registerFallbackValue(FakeUpdateOrderStatusRequest());
  });

  late MockOrderRepository repo;

  setUp(() {
    repo = MockOrderRepository();
  });

  OrderCubit buildCubit() => OrderCubit(repo);

  // ── 1. buyProduct — success (non-COD) ───────────────────────────────────────

  blocTest<OrderCubit, OrderState>(
    'buyProduct emits [loading, success] on success (non-COD)',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenAnswer((_) async => _fakeOrder());
    },
    act: (cubit) => cubit.buyProduct(_fakeBuyRequest()),
    expect: () => [
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.loading, 'loading'),
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.success, 'success'),
    ],
    verify: (_) {
      verifyNever(() => repo.initiateCODCheckout(any()));
    },
  );

  // ── 2. buyProduct — COD path ────────────────────────────────────────────────

  blocTest<OrderCubit, OrderState>(
    'buyProduct calls initiateCODCheckout when isCOD=true',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenAnswer((_) async => _fakeOrder());
      when(() => repo.initiateCODCheckout(any()))
          .thenAnswer((_) async => _fakeOrder());
    },
    act: (cubit) => cubit.buyProduct(_fakeBuyRequest(), isCOD: true),
    expect: () => [
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.loading, 'loading'),
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.success, 'success'),
    ],
    verify: (_) {
      verify(() => repo.initiateCODCheckout('ord-1')).called(1);
    },
  );

  // ── 3. buyProduct — error ────────────────────────────────────────────────────

  blocTest<OrderCubit, OrderState>(
    'buyProduct emits [loading, error] on repository failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenThrow(Exception('network error'));
    },
    act: (cubit) => cubit.buyProduct(_fakeBuyRequest()),
    expect: () => [
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.loading, 'loading'),
      predicate<OrderState>(
        (s) => s.status == OrderProcessStatus.error && s.error != null,
        'error with message',
      ),
    ],
  );

  // ── 4. loadOrders — success ──────────────────────────────────────────────────

  blocTest<OrderCubit, OrderState>(
    'loadOrders emits [loading, success] with orders on success',
    build: buildCubit,
    setUp: () {
      when(() => repo.getMyOrders(viewAs: any(named: 'viewAs'))).thenAnswer(
        (_) async => [_fakeOrder(id: 'ord-1'), _fakeOrder(id: 'ord-2')],
      );
    },
    act: (cubit) => cubit.loadOrders(viewAs: 'buyer'),
    expect: () => [
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.loading, 'loading'),
      predicate<OrderState>(
        (s) => s.status == OrderProcessStatus.success && s.orders.length == 2,
        'success with 2 orders',
      ),
    ],
  );

  // ── 5. loadOrders — error ────────────────────────────────────────────────────

  blocTest<OrderCubit, OrderState>(
    'loadOrders emits [loading, error] on failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.getMyOrders(viewAs: any(named: 'viewAs')))
          .thenThrow(Exception('server error'));
    },
    act: (cubit) => cubit.loadOrders(viewAs: 'buyer'),
    expect: () => [
      predicate<OrderState>(
          (s) => s.status == OrderProcessStatus.loading, 'loading'),
      predicate<OrderState>(
        (s) => s.status == OrderProcessStatus.error && s.error != null,
        'error state',
      ),
    ],
  );

  // ── 6. initial state ──────────────────────────────────────────────────────────

  test('initial state is OrderProcessStatus.initial with empty orders', () {
    final cubit = buildCubit();
    expect(cubit.state.status, OrderProcessStatus.initial);
    expect(cubit.state.orders, isEmpty);
    expect(cubit.state.error, isNull);
    cubit.close();
  });
}
