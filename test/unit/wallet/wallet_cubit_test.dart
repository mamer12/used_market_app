// test/unit/wallet/wallet_cubit_test.dart
//
// Unit tests for WalletCubit.
// Covers: load success, load failure, deductBalance success and
// insufficient-funds guard.
//
// NOTE: WalletState uses `sealed class` with no Equatable/==, so we use
// predicate<> matchers throughout instead of concrete class instances.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:luqta/features/wallet/presentation/cubit/wallet_cubit.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late MockWalletRepository repo;

  setUp(() {
    repo = MockWalletRepository();
  });

  WalletCubit buildCubit() => WalletCubit(repo);

  // ── 1. loadBalance — success ────────────────────────────────────────────────

  blocTest<WalletCubit, WalletState>(
    'emits [WalletLoading, WalletLoaded(150_000)] on success',
    build: buildCubit,
    setUp: () {
      when(() => repo.getBalance()).thenAnswer((_) async => 150_000);
    },
    act: (cubit) => cubit.loadBalance(),
    expect: () => [
      predicate<WalletState>((s) => s is WalletLoading, 'WalletLoading'),
      predicate<WalletState>(
        (s) => s is WalletLoaded && (s).balanceIqd == 150_000,
        'WalletLoaded(150_000)',
      ),
    ],
  );

  // ── 2. loadBalance — failure ────────────────────────────────────────────────

  blocTest<WalletCubit, WalletState>(
    'emits [WalletLoading, WalletError] on repository failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.getBalance()).thenThrow(Exception('network error'));
    },
    act: (cubit) => cubit.loadBalance(),
    expect: () => [
      predicate<WalletState>((s) => s is WalletLoading, 'WalletLoading'),
      predicate<WalletState>((s) => s is WalletError, 'WalletError'),
    ],
  );

  // ── 3. deductBalance — success ──────────────────────────────────────────────

  blocTest<WalletCubit, WalletState>(
    'deductBalance emits updated WalletLoaded balance on success',
    build: buildCubit,
    seed: () => const WalletLoaded(200_000),
    setUp: () {
      when(() => repo.deductBalance(any())).thenAnswer((_) async {});
    },
    act: (cubit) async {
      final ok = await cubit.deductBalance(50_000);
      expect(ok, isTrue);
    },
    expect: () => [
      predicate<WalletState>(
        (s) => s is WalletLoaded && (s).balanceIqd == 150_000,
        'WalletLoaded(150_000) after deduction',
      ),
    ],
  );

  // ── 4. deductBalance — insufficient funds guard ─────────────────────────────

  test(
    'deductBalance returns false and emits nothing when amount exceeds balance',
    () async {
      when(() => repo.deductBalance(any())).thenAnswer((_) async {});
      final cubit = buildCubit();
      cubit.emit(const WalletLoaded(30_000));

      final states = <WalletState>[];
      final sub = cubit.stream.listen(states.add);

      final ok = await cubit.deductBalance(50_000);

      await Future<void>.delayed(Duration.zero); // flush microtasks
      await sub.cancel();

      expect(ok, isFalse);
      expect(states, isEmpty); // no state emitted
      verifyNever(() => repo.deductBalance(any()));
      await cubit.close();
    },
  );

  // ── 5. deductBalance — repo failure ────────────────────────────────────────

  blocTest<WalletCubit, WalletState>(
    'deductBalance returns false on repo failure (no state emitted)',
    build: buildCubit,
    seed: () => const WalletLoaded(200_000),
    setUp: () {
      when(() => repo.deductBalance(any()))
          .thenThrow(Exception('payment gateway error'));
    },
    act: (cubit) async {
      final ok = await cubit.deductBalance(50_000);
      expect(ok, isFalse);
    },
    expect: () => <WalletState>[],
  );
}
