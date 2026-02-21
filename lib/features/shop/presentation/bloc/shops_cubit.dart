import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../data/models/shop_models.dart';
import '../../domain/repositories/shop_repository.dart';

// ── Shops List State ─────────────────────────────────────────────────────
class ShopsState {
  final bool isLoading;
  final List<ShopModel> shops;
  final String? error;
  final bool hasReachedEnd;
  final int page;

  const ShopsState({
    this.isLoading = false,
    this.shops = const [],
    this.error,
    this.hasReachedEnd = false,
    this.page = 1,
  });

  ShopsState copyWith({
    bool? isLoading,
    List<ShopModel>? shops,
    String? error,
    bool? hasReachedEnd,
    int? page,
  }) {
    return ShopsState(
      isLoading: isLoading ?? this.isLoading,
      shops: shops ?? this.shops,
      error: error ?? this.error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      page: page ?? this.page,
    );
  }

  ShopsState clearError() => ShopsState(
    isLoading: isLoading,
    shops: shops,
    hasReachedEnd: hasReachedEnd,
    page: page,
  );
}

// ── Shops List Cubit ─────────────────────────────────────────────────────
@injectable
class ShopsCubit extends Cubit<ShopsState> {
  final ShopRepository _shopRepository;

  ShopsCubit(this._shopRepository) : super(const ShopsState());

  Future<void> loadShops({bool refresh = false}) async {
    if (state.isLoading) return;
    if (state.hasReachedEnd && !refresh) return;

    final currentPage = refresh ? 1 : state.page;
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final newShops = await _shopRepository.listShops(
        page: currentPage,
        limit: 20,
      );
      final updatedShops = refresh ? newShops : [...state.shops, ...newShops];
      emit(
        state.copyWith(
          isLoading: false,
          shops: updatedShops,
          hasReachedEnd: newShops.length < 20,
          page: currentPage + 1,
        ),
      );
    } catch (e, st) {
      LogService().error('Failed to load shops', e, st);
      emit(state.copyWith(isLoading: false, error: 'Failed to load shops.'));
    }
  }
}

// ── Shop Products State ───────────────────────────────────────────────────
class ShopProductsState {
  final bool isLoading;
  final ShopModel? shop;
  final List<ProductModel> products;
  final String? error;
  final bool hasReachedEnd;
  final int page;

  const ShopProductsState({
    this.isLoading = false,
    this.shop,
    this.products = const [],
    this.error,
    this.hasReachedEnd = false,
    this.page = 1,
  });

  ShopProductsState copyWith({
    bool? isLoading,
    ShopModel? shop,
    List<ProductModel>? products,
    String? error,
    bool? hasReachedEnd,
    int? page,
  }) {
    return ShopProductsState(
      isLoading: isLoading ?? this.isLoading,
      shop: shop ?? this.shop,
      products: products ?? this.products,
      error: error ?? this.error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      page: page ?? this.page,
    );
  }
}

// ── Shop Products Cubit ───────────────────────────────────────────────────
@injectable
class ShopProductsCubit extends Cubit<ShopProductsState> {
  final ShopRepository _shopRepository;

  ShopProductsCubit(this._shopRepository) : super(const ShopProductsState());

  Future<void> loadCatalog(String slug, {bool refresh = false}) async {
    if (state.isLoading) return;
    if (state.hasReachedEnd && !refresh) return;

    final currentPage = refresh ? 1 : state.page;
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final (shop, newProducts) = await _shopRepository.browseShopCatalog(
        slug,
        page: currentPage,
        limit: 20,
      );
      final updated = refresh
          ? newProducts
          : [...state.products, ...newProducts];
      emit(
        state.copyWith(
          isLoading: false,
          shop: shop,
          products: updated,
          hasReachedEnd: newProducts.length < 20,
          page: currentPage + 1,
        ),
      );
    } catch (e, st) {
      LogService().error('Failed to load shop catalog', e, st);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load products.',
        ),
      );
    }
  }
}
