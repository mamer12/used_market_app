// test/unit/auction/auctions_cubit_test.dart
//
// Unit tests for AuctionsCubit.
// Covers: loadAuctions success + filtering, error handling,
// filter/sort mutation, loadMyBids, loadWatchedAuctions,
// deduplication guard (isLoading), and hasReachedMax.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auction/data/models/auction_models.dart';
import 'package:luqta/features/auction/domain/repositories/auction_repository.dart';
import 'package:luqta/features/auction/presentation/bloc/auctions_cubit.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockAuctionRepository extends Mock implements AuctionRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
AuctionModel _liveAuction({
  String id = 'auc-1',
  String status = 'live',
  DateTime? endTime,
}) =>
    AuctionModel(
      id: id,
      title: 'مزاد تجريبي',
      description: '',
      startPrice: 10_000,
      currentPrice: 15_000,
      status: status,
      endTime: endTime ?? DateTime.now().add(const Duration(hours: 2)),
    );

BidModel _bid({String id = 'bid-1'}) => BidModel(
      id: id,
      bidderId: 'user-001',
      amount: 20_000,
      createdAt: DateTime.now(),
    );

void main() {
  late MockAuctionRepository repo;

  setUp(() {
    repo = MockAuctionRepository();

    // Silence stream stubs required by AuctionRepository interface
    when(() => repo.liveBidStream).thenAnswer((_) => const Stream.empty());
    when(() => repo.auctionEndedStream).thenAnswer((_) => const Stream.empty());
    when(() => repo.auctionErrorStream).thenAnswer((_) => const Stream.empty());
  });

  AuctionsCubit buildCubit() => AuctionsCubit(repo);

  // ── 1. loadAuctions — happy path ────────────────────────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadAuctions emits [loading, loaded] with live auctions filtered',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [_liveAuction()]);
    },
    act: (cubit) => cubit.loadAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoading, 'loading'),
      predicate<AuctionsState>(
        (s) => !s.isLoading && s.auctions.length == 1,
        'loaded with 1 auction',
      ),
    ],
  );

  // ── 2. Ended auctions are filtered out ────────────────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadAuctions skips auctions with status==ended',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => [
          _liveAuction(id: 'live-1', status: 'live'),
          _liveAuction(id: 'ended-1', status: 'ended'),
        ],
      );
    },
    act: (cubit) => cubit.loadAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoading, 'loading'),
      predicate<AuctionsState>(
        (s) => !s.isLoading && s.auctions.length == 1 && s.auctions[0].id == 'live-1',
        'only live auction retained',
      ),
    ],
  );

  // ── 3. Auctions with past endTime are filtered out ────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadAuctions skips live auctions whose endTime has already passed',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => [
          _liveAuction(
            id: 'past-1',
            status: 'live',
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          _liveAuction(id: 'future-1'),
        ],
      );
    },
    act: (cubit) => cubit.loadAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoading, 'loading'),
      predicate<AuctionsState>(
        (s) =>
            !s.isLoading &&
            s.auctions.length == 1 &&
            s.auctions[0].id == 'future-1',
        'expired auction removed, future auction retained',
      ),
    ],
  );

  // ── 4. Error handling ────────────────────────────────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadAuctions emits error state on repository failure',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('server down'));
    },
    act: (cubit) => cubit.loadAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoading, 'loading'),
      predicate<AuctionsState>(
        (s) => !s.isLoading && s.error != null,
        'error emitted',
      ),
    ],
  );

  // ── 5. hasReachedMax when fewer than 20 results ──────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'sets hasReachedMax=true when repo returns fewer than 20 auctions',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [_liveAuction()]); // 1 < 20
    },
    act: (cubit) => cubit.loadAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoading),
      predicate<AuctionsState>(
        (s) => !s.isLoading && s.hasReachedMax,
        'hasReachedMax set',
      ),
    ],
  );

  // ── 6. Sort/filter mutation methods ──────────────────────────────────────

  // Use blocTest so the async loadAuctions call triggered by setFilterStatus
  // completes before the cubit is closed (avoids "emit after close" error).

  blocTest<AuctionsCubit, AuctionsState>(
    'setFilterStatus updates filterStatus and resets page',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    },
    act: (cubit) => cubit.setFilterStatus('upcoming'),
    verify: (cubit) {
      expect(cubit.state.filterStatus, 'upcoming');
      expect(cubit.state.page, 1);
    },
  );

  blocTest<AuctionsCubit, AuctionsState>(
    'setSortBy updates sortBy and resets page',
    build: buildCubit,
    setUp: () {
      when(
        () => repo.getLiveAuctions(
          category: any(named: 'category'),
          condition: any(named: 'condition'),
          sortBy: any(named: 'sortBy'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    },
    act: (cubit) => cubit.setSortBy('price_asc'),
    verify: (cubit) {
      expect(cubit.state.sortBy, 'price_asc');
      expect(cubit.state.page, 1);
    },
  );

  // ── 7. loadMyBids ────────────────────────────────────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadMyBids emits bids on success',
    build: buildCubit,
    setUp: () {
      when(() => repo.getMyBids()).thenAnswer((_) async => [_bid()]);
    },
    act: (cubit) => cubit.loadMyBids(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoadingMyBids, 'loading bids'),
      predicate<AuctionsState>(
        (s) => !s.isLoadingMyBids && s.myBids.length == 1,
        'bids loaded',
      ),
    ],
  );

  blocTest<AuctionsCubit, AuctionsState>(
    'loadMyBids stops loading on failure',
    build: buildCubit,
    setUp: () {
      when(() => repo.getMyBids()).thenThrow(Exception('Unauthorized'));
    },
    act: (cubit) => cubit.loadMyBids(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoadingMyBids),
      predicate<AuctionsState>(
        (s) => !s.isLoadingMyBids && s.myBids.isEmpty,
        'loading cleared, bids still empty',
      ),
    ],
  );

  // ── 8. loadWatchedAuctions ───────────────────────────────────────────────

  blocTest<AuctionsCubit, AuctionsState>(
    'loadWatchedAuctions emits watchedAuctions on success',
    build: buildCubit,
    setUp: () {
      when(() => repo.getWatchedAuctions())
          .thenAnswer((_) async => [_liveAuction(id: 'watched-1')]);
    },
    act: (cubit) => cubit.loadWatchedAuctions(),
    expect: () => [
      predicate<AuctionsState>((s) => s.isLoadingWatchlist),
      predicate<AuctionsState>(
        (s) => !s.isLoadingWatchlist && s.watchedAuctions.length == 1,
        'watchlist loaded',
      ),
    ],
  );
}
