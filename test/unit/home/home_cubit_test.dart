// test/unit/home/home_cubit_test.dart
//
// Unit tests for HomeCubit.
// Covers: portal-endpoint success, connectivity error fast-fail,
// legacy parallel-fetch fallback, and generic error handling.
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auction/data/models/auction_models.dart';
import 'package:luqta/features/auction/domain/repositories/auction_repository.dart';
import 'package:luqta/features/home/presentation/bloc/home_cubit.dart';
import 'package:luqta/features/shop/data/models/shop_models.dart';
import 'package:luqta/features/shop/domain/repositories/shop_repository.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockAuctionRepository extends Mock implements AuctionRepository {}
class MockShopRepository extends Mock implements ShopRepository {}
class MockDio extends Mock implements Dio {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
// Minimal AuctionModel fixture — only required fields.
AuctionModel _fakeAuction({String id = 'auc-1', String status = 'live'}) =>
    AuctionModel(
      id: id,
      title: 'مزاد تجريبي',
      status: status,
      endTime: DateTime.now().add(const Duration(hours: 2)),
    );

// Minimal ShopModel fixture — only required fields.
ShopModel _fakeShop({String slug = 'shop-1'}) => ShopModel(
      id: 'shp-$slug',
      name: 'متجر تجريبي',
      slug: slug,
    );

void main() {
  late MockAuctionRepository auctionRepo;
  late MockShopRepository shopRepo;
  late MockDio dio;

  setUp(() {
    auctionRepo = MockAuctionRepository();
    shopRepo    = MockShopRepository();
    dio         = MockDio();
  });

  HomeCubit buildCubit() => HomeCubit(auctionRepo, shopRepo, dio);

  // ── 1. Portal endpoint succeeds ─────────────────────────────────────────────

  blocTest<HomeCubit, HomeState>(
    'emits loaded state with liveAuctions from portal on success',
    build: buildCubit,
    setUp: () {
      final portalData = {
        'mazadat': [
          {
            'id': 'auc-1',
            'title': 'مزاد تجريبي',
            'description': '',
            'starting_price': 10000,
            'current_price': 15000,
            'min_bid_increment': 500,
            'currency': 'IQD',
            'status': 'live',
            'end_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'images': <String>[],
            'seller_name': 'البائع',
          }
        ],
        'matajir': <dynamic>[],
        'balla': <dynamic>[],
        'mustamal': <dynamic>[],
        'announcements': <dynamic>[],
      };

      when(() => dio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: portalData,
        ),
      );
    },
    act: (cubit) => cubit.loadFeed(),
    expect: () => [
      predicate<HomeState>((s) => s.isLoading, 'loading'),
      predicate<HomeState>(
        (s) => !s.isLoading && s.liveAuctions.isNotEmpty,
        'loaded with liveAuctions',
      ),
    ],
    verify: (_) {
      // Shop and auction repos should NOT be called when portal succeeds
      verifyNever(() => auctionRepo.getLiveAuctions());
    },
  );

  // ── 2. Connectivity error fast-fail ─────────────────────────────────────────

  blocTest<HomeCubit, HomeState>(
    'emits error with Arabic connectivity message on connection timeout',
    build: buildCubit,
    setUp: () {
      when(() => dio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );
    },
    act: (cubit) => cubit.loadFeed(),
    expect: () => [
      predicate<HomeState>((s) => s.isLoading, 'loading'),
      predicate<HomeState>(
        (s) => !s.isLoading && (s.error?.contains('اتصال') ?? false),
        'connectivity error emitted',
      ),
    ],
  );

  // ── 3. Legacy fallback (portal returns 500) ─────────────────────────────────

  blocTest<HomeCubit, HomeState>(
    'falls back to legacy auction+shop fetch when portal returns server error',
    build: buildCubit,
    setUp: () {
      // Portal returns 500
      when(() => dio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Legacy repos succeed
      when(
        () => auctionRepo.getLiveAuctions(limit: any(named: 'limit')),
      ).thenAnswer((_) async => [_fakeAuction()]);

      when(
        () => shopRepo.listShops(limit: any(named: 'limit')),
      ).thenAnswer((_) async => [_fakeShop()]);

      when(
        () => shopRepo.browseShopCatalog(
          any(),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => (_fakeShop(), <ProductModel>[]));
    },
    act: (cubit) => cubit.loadFeed(),
    expect: () => [
      predicate<HomeState>((s) => s.isLoading, 'loading'),
      predicate<HomeState>(
        (s) => !s.isLoading && s.liveAuctions.isNotEmpty,
        'loaded with legacy data',
      ),
    ],
    verify: (_) {
      verify(
        () => auctionRepo.getLiveAuctions(limit: any(named: 'limit')),
      ).called(1);
      verify(
        () => shopRepo.listShops(limit: any(named: 'limit')),
      ).called(1);
    },
  );

  // ── 4. Generic error ────────────────────────────────────────────────────────

  blocTest<HomeCubit, HomeState>(
    'emits error state on unexpected exception',
    build: buildCubit,
    setUp: () {
      when(() => dio.get(any())).thenThrow(Exception('Unexpected'));
      when(
        () => auctionRepo.getLiveAuctions(limit: any(named: 'limit')),
      ).thenThrow(Exception('Unexpected'));
      when(
        () => shopRepo.listShops(limit: any(named: 'limit')),
      ).thenThrow(Exception('Unexpected'));
    },
    act: (cubit) => cubit.loadFeed(),
    expect: () => [
      predicate<HomeState>((s) => s.isLoading, 'loading'),
      predicate<HomeState>(
        (s) => !s.isLoading && s.error != null,
        'error emitted',
      ),
    ],
  );
}
