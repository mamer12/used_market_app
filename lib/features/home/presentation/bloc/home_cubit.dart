import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/log_service.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/domain/repositories/auction_repository.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/domain/repositories/shop_repository.dart';
import '../../data/models/portal_models.dart';

// ── Shop catalog entry (shop + its products) ─────────────────────────────
class ShopCatalogEntry {
  final ShopModel shop;
  final List<ProductModel> products;
  const ShopCatalogEntry({required this.shop, required this.products});
}

// ── State ─────────────────────────────────────────────────────────────────
class HomeState {
  final bool isLoading;
  // Portal feed (new polymorphic response)
  final SuperAppPortalResponse portal;
  // Legacy fields — still populated from parallel requests for backwards compat
  final List<AuctionModel> liveAuctions;
  final List<ProductModel> featuredProducts;
  final List<ShopCatalogEntry> shopCatalogs;
  // Announcements carousel — sourced from portal or synthesised locally
  final List<Announcement> announcements;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.portal = SuperAppPortalResponse.empty,
    this.liveAuctions = const [],
    this.featuredProducts = const [],
    this.shopCatalogs = const [],
    this.announcements = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    SuperAppPortalResponse? portal,
    List<AuctionModel>? liveAuctions,
    List<ProductModel>? featuredProducts,
    List<ShopCatalogEntry>? shopCatalogs,
    List<Announcement>? announcements,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      portal: portal ?? this.portal,
      liveAuctions: liveAuctions ?? this.liveAuctions,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      shopCatalogs: shopCatalogs ?? this.shopCatalogs,
      announcements: announcements ?? this.announcements,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Cubit ──────────────────────────────────────────────────────────────────
@injectable
class HomeCubit extends Cubit<HomeState> {
  final AuctionRepository _auctionRepository;
  final ShopRepository _shopRepository;
  final Dio _dio;

  HomeCubit(this._auctionRepository, this._shopRepository, this._dio)
    : super(const HomeState());

  Future<void> loadFeed() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // 1. Try the new unified portal endpoint first.
      //    Falls back to parallel requests if the backend hasn't been updated.
      SuperAppPortalResponse? portal;
      bool isConnectivityError = false;
      try {
        final response = await _dio.get(ApiConstants.mobileHome);
        portal = SuperAppPortalResponse.fromJson(response.data);
      } on DioException catch (e) {
        // If the failure is a connectivity / timeout issue, skip the legacy
        // parallel endpoints — they will fail for the same reason and just
        // add another 15 s of dead waiting.
        isConnectivityError = const {
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.connectionError,
        }.contains(e.type);
        portal = null;
      } catch (_) {
        portal = null;
      }

      // If the portal succeeded, skip legacy parallel fetch entirely.
      if (portal != null) {
        final announcements = portal.announcements.isNotEmpty
            ? portal.announcements
            : _synthesiseAnnouncements(portal.mazadat, portal.matajir);

        emit(
          state.copyWith(
            isLoading: false,
            portal: portal,
            liveAuctions: portal.mazadat,
            featuredProducts: portal.balla,
            shopCatalogs: const [],
            announcements: announcements,
          ),
        );
        return;
      }

      // If we know the network is unreachable, fail fast instead of
      // waiting another 15+ s for legacy endpoints to time out.
      if (isConnectivityError) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'تعذر الاتصال بالخادم — تحقق من اتصالك بالإنترنت',
          ),
        );
        return;
      }

      // 2. Legacy parallel fetch (portal endpoint returned a server error or
      //    isn't deployed yet).
      final topLevel = await Future.wait([
        _auctionRepository.getLiveAuctions(limit: 8),
        _shopRepository.listShops(limit: 6),
      ]);

      final auctions = topLevel[0] as List<AuctionModel>;
      final shops = topLevel[1] as List<ShopModel>;

      // 3. Fetch each shop's catalog concurrently (failures swallowed)
      final catalogResults = await Future.wait(
        shops.map(
          (s) => _shopRepository
              .browseShopCatalog(s.slug, limit: 8)
              .catchError((_) => (s, <ProductModel>[])),
        ),
      );

      final catalogs = catalogResults
          .map((r) => ShopCatalogEntry(shop: r.$1, products: r.$2))
          .where((e) => e.products.isNotEmpty)
          .toList();

      final allProducts = catalogs.expand((e) => e.products).take(12).toList();

      // 4. Synthesise portal from legacy data when the dedicated endpoint
      //    isn't yet deployed.
      final ballaProducts = allProducts.where((p) => p.isBalla).toList();
      final matajirShops = shops;

      final fallbackPortal = SuperAppPortalResponse(
        mazadat: auctions,
        mustamal: const [], // populated once /mobile/home endpoint exists
        matajir: matajirShops,
        balla: ballaProducts,
      );

      // 5. Synthesise announcements from live portal data, or use static
      //    placeholders until the backend surfaces an `announcements` array.
      final announcements =
          _synthesiseAnnouncements(auctions, shops);

      emit(
        state.copyWith(
          isLoading: false,
          portal: fallbackPortal,
          liveAuctions: auctions,
          featuredProducts: allProducts,
          shopCatalogs: catalogs,
          announcements: announcements,
        ),
      );
    } on DioException catch (e, st) {
      LogService().error('Failed to load home feed', e, st);
      final msg = _isConnectivityDioError(e)
          ? 'تعذر الاتصال بالخادم — تحقق من اتصالك بالإنترنت'
          : 'فشل تحميل الصفحة الرئيسية: ${e.message}';
      emit(state.copyWith(isLoading: false, error: msg));
    } catch (e, st) {
      LogService().error('Failed to load home feed', e, st);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'فشل تحميل الصفحة الرئيسية',
        ),
      );
    }
  }

  static bool _isConnectivityDioError(DioException e) {
    return const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    }.contains(e.type);
  }

  /// Builds static/synthesised announcements from fetched data until the
  /// `/mobile/home` backend endpoint exposes a real `announcements` array.
  List<Announcement> _synthesiseAnnouncements(
    List<AuctionModel> auctions,
    List<ShopModel> shops,
  ) {
    final list = <Announcement>[];

    // Slot 1 — Mazadat promo
    if (auctions.isNotEmpty) {
      list.add(
        Announcement(
          id: 'mazadat-promo',
          title: 'مزادات لايف الآن 🔴',
          subtitle: 'زايد على أحلى العروض قبل فوات الأوان',
          imageUrl: auctions.first.images.isNotEmpty
              ? auctions.first.images.first
              : null,
          deepLink: '/mazadat',
          badgeText: 'مباشر',
          colorHex: 0xFF1A1A1A,
        ),
      );
    }

    // Slot 2 — Matajir promo
    if (shops.isNotEmpty) {
      list.add(
        const Announcement(
          id: 'matajir-promo',
          title: 'تسوق من أشهر المتاجر',
          subtitle: 'منتجات أصلية بأسعار تنافسية',
          imageUrl: null,
          deepLink: '/matajir',
          badgeText: 'جديد',
          colorHex: 0xFF1565C0,
        ),
      );
    }

    // Slot 3 — Balla promo (always)
    list.add(
      const Announcement(
        id: 'balla-promo',
        title: 'سوق البالة — كنوز بأسعار الجملة',
        subtitle: 'اشتري بالقطعة أو الكيلو أو البالة',
        deepLink: '/balla',
        badgeText: 'بالة',
        colorHex: 0xFF4A148C,
      ),
    );

    return list;
  }
}
