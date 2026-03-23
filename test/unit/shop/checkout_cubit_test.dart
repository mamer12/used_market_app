// test/unit/shop/checkout_cubit_test.dart
//
// Unit tests for CheckoutCubit.
// Covers: initial state, loading on submit, COD success, ZainCash success,
// error handling, reset action.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/shop/data/models/order_models.dart';
import 'package:luqta/features/shop/domain/repositories/order_repository.dart';
import 'package:luqta/features/shop/presentation/bloc/checkout_cubit.dart';

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
  String id = 'ord-42',
  String? paymentUrl,
}) =>
    OrderModel(
      id: id,
      productId: 'prod-1',
      buyerId: 'buyer-1',
      sellerId: 'seller-1',
      quantity: 1,
      totalPrice: 75000,
      status: OrderStatus.pendingPayment,
      shippingAddress: _kAddress,
      fulfillmentType: 'escrow',
      paymentUrl: paymentUrl,
    );

BuyProductRequest _fakeRequest() => const BuyProductRequest(
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

  CheckoutCubit buildCubit() => CheckoutCubit(repo);

  // ── 1. Initial state ────────────────────────────────────────────────────────

  test('initial state is CheckoutProcessStatus.initial', () {
    final cubit = buildCubit();
    expect(cubit.state.status, CheckoutProcessStatus.initial);
    expect(cubit.state.orderId, isNull);
    expect(cubit.state.paymentUrl, isNull);
    expect(cubit.state.error, isNull);
    cubit.close();
  });

  // ── 2. COD path ─────────────────────────────────────────────────────────────

  blocTest<CheckoutCubit, CheckoutState>(
    'placeOrder COD: emits [loading, success] and calls initiateCODCheckout',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenAnswer((_) async => _fakeOrder());
      when(() => repo.initiateCODCheckout(any()))
          .thenAnswer((_) async => _fakeOrder());
    },
    act: (cubit) => cubit.placeOrder(_fakeRequest(), paymentMethod: 'cod'),
    expect: () => [
      predicate<CheckoutState>(
          (s) => s.status == CheckoutProcessStatus.loading, 'loading'),
      predicate<CheckoutState>(
        (s) =>
            s.status == CheckoutProcessStatus.success &&
            s.orderId == 'ord-42' &&
            s.paymentMethod == 'cod' &&
            s.paymentUrl == null,
        'success COD — orderId set, no paymentUrl',
      ),
    ],
    verify: (_) {
      verify(() => repo.initiateCODCheckout('ord-42')).called(1);
    },
  );

  // ── 3. ZainCash path ─────────────────────────────────────────────────────────

  blocTest<CheckoutCubit, CheckoutState>(
    'placeOrder ZainCash: emits [loading, success] with paymentUrl',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any())).thenAnswer(
        (_) async =>
            _fakeOrder(paymentUrl: 'https://zaincash.iq/pay/token-abc'),
      );
    },
    act: (cubit) =>
        cubit.placeOrder(_fakeRequest(), paymentMethod: 'zaincash'),
    expect: () => [
      predicate<CheckoutState>(
          (s) => s.status == CheckoutProcessStatus.loading, 'loading'),
      predicate<CheckoutState>(
        (s) =>
            s.status == CheckoutProcessStatus.success &&
            s.orderId == 'ord-42' &&
            s.paymentMethod == 'zaincash' &&
            s.paymentUrl == 'https://zaincash.iq/pay/token-abc',
        'success ZainCash — orderId + paymentUrl set',
      ),
    ],
    verify: (_) {
      verifyNever(() => repo.initiateCODCheckout(any()));
    },
  );

  // ── 4. Error handling ────────────────────────────────────────────────────────

  blocTest<CheckoutCubit, CheckoutState>(
    'placeOrder emits [loading, error] on repository failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenThrow(Exception('payment gateway timeout'));
    },
    act: (cubit) => cubit.placeOrder(_fakeRequest(), paymentMethod: 'cod'),
    expect: () => [
      predicate<CheckoutState>(
          (s) => s.status == CheckoutProcessStatus.loading, 'loading'),
      predicate<CheckoutState>(
        (s) =>
            s.status == CheckoutProcessStatus.error &&
            s.error != null &&
            s.error!.contains('payment gateway timeout'),
        'error with message',
      ),
    ],
  );

  // ── 5. COD checkout failure after order created ───────────────────────────

  blocTest<CheckoutCubit, CheckoutState>(
    'placeOrder emits error when COD initiation fails after order creation',
    build: buildCubit,
    setUp: () {
      when(() => repo.buyShopProduct(any()))
          .thenAnswer((_) async => _fakeOrder());
      when(() => repo.initiateCODCheckout(any()))
          .thenThrow(Exception('COD service unavailable'));
    },
    act: (cubit) => cubit.placeOrder(_fakeRequest(), paymentMethod: 'cod'),
    expect: () => [
      predicate<CheckoutState>(
          (s) => s.status == CheckoutProcessStatus.loading, 'loading'),
      predicate<CheckoutState>(
        (s) => s.status == CheckoutProcessStatus.error && s.error != null,
        'error state after COD initiation failure',
      ),
    ],
  );

  // ── 6. Reset ─────────────────────────────────────────────────────────────────

  blocTest<CheckoutCubit, CheckoutState>(
    'reset clears state back to initial',
    build: buildCubit,
    seed: () => const CheckoutState(
      status: CheckoutProcessStatus.success,
      orderId: 'ord-99',
      paymentMethod: 'cod',
    ),
    act: (cubit) => cubit.reset(),
    expect: () => [
      predicate<CheckoutState>(
        (s) =>
            s.status == CheckoutProcessStatus.initial &&
            s.orderId == null &&
            s.error == null,
        'reset to initial',
      ),
    ],
  );
}
