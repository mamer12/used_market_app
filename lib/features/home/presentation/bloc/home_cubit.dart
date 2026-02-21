import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/domain/repositories/auction_repository.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/domain/repositories/shop_repository.dart';

// ── State ────────────────────────────────────────────────────────────────
class HomeState {
  final bool isLoading;
  final List<AuctionModel> liveAuctions;
  final List<ProductModel> featuredProducts;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.liveAuctions = const [],
    this.featuredProducts = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<AuctionModel>? liveAuctions,
    List<ProductModel>? featuredProducts,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      liveAuctions: liveAuctions ?? this.liveAuctions,
      featuredProducts: featuredProducts ?? this.featuredProducts,
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
      final results = await Future.wait([
        _auctionRepository.getLiveAuctions(limit: 5),
        // Providing a default generic slug to fetch the shop's catalog.
        // In a real scenario, this might be a dedicated feed API endpoint.
        _shopRepository
            .browseShopCatalog('electro-iq-922197', limit: 5)
            .catchError((_) => <ProductModel>[]),
      ]);

      final auctions = results[0] as List<AuctionModel>;
      final products = results[1] as List<ProductModel>;

      emit(
        state.copyWith(
          isLoading: false,
          liveAuctions: auctions,
          featuredProducts: products,
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
