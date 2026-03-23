// test/unit/orders/order_tracking_cubit_test.dart
//
// Unit tests for OrderTrackingCubit.
// Covers: initial state, loading → loaded with each escrow status, error,
// confirmDelivery success/error, refresh with and without loaded order.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/shop/data/models/order_models.dart';
import 'package:luqta/features/shop/domain/repositories/order_repository.dart';
import 'package:luqta/features/orders/presentation/cubit/order_tracking_cubit.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockOrderRepository extends Mock implements OrderRepository {}

class FakeBuyProductRequest extends Fake implements BuyProductRequest {}

class FakeUpdateOrderStatusRequest extends Fake
    implements UpdateOrderStatusRequest {}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _kAddress = ShippingAddress(
  city: 'Baghdad',
  district: 'Mansour',
  street: 'Al-Kindi St',
  building: '7',
  phone: '+9647901234567',
);

OrderModel _fakeOrderWithStatus(OrderStatus status) => OrderModel(
      id: 'ord-100',
      productId: 'prod-5',
      buyerId: 'buyer-2',
      sellerId: 'seller-2',
      quantity: 1,
      totalPrice: 120000,
      status: status,
      shippingAddress: _kAddress,
      fulfillmentType: 'escrow',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuyProductRequest());
    registerFallbackValue(FakeUpdateOrderStatusRequest());
    registerFallbackValue(const UpdateOrderStatusRequest(
      status: OrderStatus.delivered,
    ));
  });

  late MockOrderRepository repo;

  setUp(() {
    repo = MockOrderRepository();
  });

  OrderTrackingCubit buildCubit() => OrderTrackingCubit(repo);

  // ── 1. Initial state ────────────────────────────────────────────────────────

  test('initial state is OrderTrackingStatus.initial with no order', () {
    final cubit = buildCubit();
    expect(cubit.state.status, OrderTrackingStatus.initial);
    expect(cubit.state.order, isNull);
    expect(cubit.state.error, isNull);
    cubit.close();
  });

  // ── 2. loadOrder — loading then loaded ──────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'loadOrder emits [loading, loaded] on success',
    build: buildCubit,
    setUp: () {
      when(() => repo.getOrderById(any())).thenAnswer(
        (_) async => _fakeOrderWithStatus(OrderStatus.pendingPayment),
      );
    },
    act: (cubit) => cubit.loadOrder('ord-100'),
    expect: () => [
      predicate<OrderTrackingState>(
          (s) => s.status == OrderTrackingStatus.loading, 'loading'),
      predicate<OrderTrackingState>(
        (s) =>
            s.status == OrderTrackingStatus.loaded &&
            s.order?.id == 'ord-100' &&
            s.order?.status == OrderStatus.pendingPayment,
        'loaded with pendingPayment order',
      ),
    ],
  );

  // ── 3. Each escrow status loads correctly ────────────────────────────────────

  for (final escrowStatus in [
    OrderStatus.pendingPayment,
    OrderStatus.paidToEscrow,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.fundsReleased,
    OrderStatus.disputed,
    OrderStatus.refunded,
  ]) {
    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'loadOrder loads order with status $escrowStatus',
      build: buildCubit,
      setUp: () {
        when(() => repo.getOrderById(any())).thenAnswer(
          (_) async => _fakeOrderWithStatus(escrowStatus),
        );
      },
      act: (cubit) => cubit.loadOrder('ord-100'),
      expect: () => [
        predicate<OrderTrackingState>(
            (s) => s.status == OrderTrackingStatus.loading, 'loading'),
        predicate<OrderTrackingState>(
          (s) =>
              s.status == OrderTrackingStatus.loaded &&
              s.order?.status == escrowStatus,
          'loaded with $escrowStatus',
        ),
      ],
    );
  }

  // ── 4. loadOrder — error ─────────────────────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'loadOrder emits [loading, error] on repository failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.getOrderById(any()))
          .thenThrow(Exception('order not found'));
    },
    act: (cubit) => cubit.loadOrder('ord-999'),
    expect: () => [
      predicate<OrderTrackingState>(
          (s) => s.status == OrderTrackingStatus.loading, 'loading'),
      predicate<OrderTrackingState>(
        (s) =>
            s.status == OrderTrackingStatus.error &&
            s.error != null &&
            s.error!.contains('order not found'),
        'error with message',
      ),
    ],
  );

  // ── 5. confirmDelivery — success ─────────────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'confirmDelivery emits [updating, loaded] with delivered status on success',
    build: buildCubit,
    seed: () => OrderTrackingState(
      status: OrderTrackingStatus.loaded,
      order: _fakeOrderWithStatus(OrderStatus.shipped),
    ),
    setUp: () {
      when(() => repo.updateOrderStatus(any(), any())).thenAnswer(
        (_) async => _fakeOrderWithStatus(OrderStatus.delivered),
      );
    },
    act: (cubit) => cubit.confirmDelivery('ord-100'),
    expect: () => [
      predicate<OrderTrackingState>(
          (s) => s.status == OrderTrackingStatus.updating, 'updating'),
      predicate<OrderTrackingState>(
        (s) =>
            s.status == OrderTrackingStatus.loaded &&
            s.order?.status == OrderStatus.delivered,
        'loaded with delivered status',
      ),
    ],
    verify: (_) {
      verify(
        () => repo.updateOrderStatus(
          'ord-100',
          any(),
        ),
      ).called(1);
    },
  );

  // ── 6. confirmDelivery — error ────────────────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'confirmDelivery emits [updating, error] on failure',
    build: buildCubit,
    seed: () => OrderTrackingState(
      status: OrderTrackingStatus.loaded,
      order: _fakeOrderWithStatus(OrderStatus.shipped),
    ),
    setUp: () {
      when(() => repo.updateOrderStatus(any(), any()))
          .thenThrow(Exception('server error'));
    },
    act: (cubit) => cubit.confirmDelivery('ord-100'),
    expect: () => [
      predicate<OrderTrackingState>(
          (s) => s.status == OrderTrackingStatus.updating, 'updating'),
      predicate<OrderTrackingState>(
        (s) => s.status == OrderTrackingStatus.error && s.error != null,
        'error state',
      ),
    ],
  );

  // ── 7. refresh — re-fetches current order ────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'refresh calls loadOrder with current orderId when order is loaded',
    build: buildCubit,
    seed: () => OrderTrackingState(
      status: OrderTrackingStatus.loaded,
      order: _fakeOrderWithStatus(OrderStatus.shipped),
    ),
    setUp: () {
      when(() => repo.getOrderById('ord-100')).thenAnswer(
        (_) async => _fakeOrderWithStatus(OrderStatus.delivered),
      );
    },
    act: (cubit) => cubit.refresh(),
    expect: () => [
      predicate<OrderTrackingState>(
          (s) => s.status == OrderTrackingStatus.loading, 'loading'),
      predicate<OrderTrackingState>(
        (s) =>
            s.status == OrderTrackingStatus.loaded &&
            s.order?.status == OrderStatus.delivered,
        'loaded with refreshed status',
      ),
    ],
  );

  // ── 8. refresh — no-op when no order ─────────────────────────────────────────

  blocTest<OrderTrackingCubit, OrderTrackingState>(
    'refresh does nothing when no order is loaded',
    build: buildCubit,
    // No seed — stays at initial (order is null)
    act: (cubit) => cubit.refresh(),
    expect: () => <OrderTrackingState>[],
    verify: (_) {
      verifyNever(() => repo.getOrderById(any()));
    },
  );
}
