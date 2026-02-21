import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/domain/repositories/auction_repository.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/domain/repositories/shop_repository.dart';

// ── Shop catalog entry (shop + its products) ──────────────────────────────
class ShopCatalogEntry {
  final ShopModel shop;
  final List<ProductModel> products;
  const ShopCatalogEntry({required this.shop, required this.products});
}

// ── State ────────────────────────────────────────────────────────────────
class HomeState {
  final bool isLoading;
  final List<AuctionModel> liveAuctions;
  final List<ProductModel> featuredProducts;
  final List<ShopCatalogEntry> shopCatalogs;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.liveAuctions = const [],
    this.featuredProducts = const [],
    this.shopCatalogs = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<AuctionModel>? liveAuctions,
    List<ProductModel>? featuredProducts,
    List<ShopCatalogEntry>? shopCatalogs,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      liveAuctions: liveAuctions ?? this.liveAuctions,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      shopCatalogs: shopCatalogs ?? this.shopCatalogs,
      error: error ?? this.error,
    );
  }
}

// ── Cubit ────────────────────────────────────────────────────────────────
@injectable
class HomeCubit extends Cubit<HomeState> {
  final AuctionRepository _auctionRepository;
  final ShopRepository _shopRepository;

  HomeCubit(this._auctionRepository, this._shopRepository)
    : super(const HomeState());

  Future<void> loadFeed() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // 1. Fetch live auctions and the shops list in parallel
      final topLevel = await Future.wait([
        _auctionRepository.getLiveAuctions(limit: 5),
        _shopRepository.listShops(limit: 6),
      ]);

      final auctions = topLevel[0] as List<AuctionModel>;
      final shops = topLevel[1] as List<ShopModel>;

      // 2. For each shop fetch its catalog concurrently (failures are swallowed)
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

      final allProducts =
          catalogs.expand((e) => e.products).take(10).toList();

      emit(
        state.copyWith(
          isLoading: false,
          liveAuctions: auctions,
          featuredProducts: allProducts,
          shopCatalogs: catalogs,
        ),
      );
    } catch (e, st) {
      LogService().error('Failed to load home feed', e, st);
      emit(
        state.copyWith(isLoading: false, error: 'Failed to build home feed.'),
      );
    }
  }
}
