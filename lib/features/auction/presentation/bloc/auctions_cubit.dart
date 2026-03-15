import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../data/models/auction_models.dart';
import '../../domain/repositories/auction_repository.dart';

class AuctionsState {
  final bool isLoading;
  final List<AuctionModel> auctions;
  final String? error;
  final String? category;
  final String? condition;
  final String sortBy;
  final String filterStatus;
  final int page;
  final bool hasReachedMax;
  final List<BidModel> myBids;
  final bool isLoadingMyBids;
  final List<AuctionModel> watchedAuctions;
  final bool isLoadingWatchlist;

  const AuctionsState({
    this.isLoading = false,
    this.auctions = const [],
    this.error,
    this.category,
    this.condition,
    this.sortBy = 'ending_soon',
    this.filterStatus = 'live',
    this.page = 1,
    this.hasReachedMax = false,
    this.myBids = const [],
    this.isLoadingMyBids = false,
    this.watchedAuctions = const [],
    this.isLoadingWatchlist = false,
  });

  AuctionsState copyWith({
    bool? isLoading,
    List<AuctionModel>? auctions,
    String? error,
    String? category,
    String? condition,
    String? sortBy,
    String? filterStatus,
    int? page,
    bool? hasReachedMax,
    List<BidModel>? myBids,
    bool? isLoadingMyBids,
    List<AuctionModel>? watchedAuctions,
    bool? isLoadingWatchlist,
  }) {
    return AuctionsState(
      isLoading: isLoading ?? this.isLoading,
      auctions: auctions ?? this.auctions,
      error: error ?? this.error,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      sortBy: sortBy ?? this.sortBy,
      filterStatus: filterStatus ?? this.filterStatus,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      myBids: myBids ?? this.myBids,
      isLoadingMyBids: isLoadingMyBids ?? this.isLoadingMyBids,
      watchedAuctions: watchedAuctions ?? this.watchedAuctions,
      isLoadingWatchlist: isLoadingWatchlist ?? this.isLoadingWatchlist,
    );
  }
}

@injectable
class AuctionsCubit extends Cubit<AuctionsState> {
  final AuctionRepository _repository;

  AuctionsCubit(this._repository) : super(const AuctionsState());

  void setFilterStatus(String status) {
    emit(
      state.copyWith(
        filterStatus: status,
        page: 1,
        hasReachedMax: false,
        auctions: [],
      ),
    );
    loadAuctions();
  }

  void setSortBy(String sortBy) {
    emit(
      state.copyWith(
        sortBy: sortBy,
        page: 1,
        hasReachedMax: false,
        auctions: [],
      ),
    );
    loadAuctions();
  }

  void setCategory(String? category) {
    emit(
      state.copyWith(
        category: category,
        page: 1,
        hasReachedMax: false,
        auctions: [],
      ),
    );
    loadAuctions();
  }

  void setCondition(String? condition) {
    emit(
      state.copyWith(
        condition: condition,
        page: 1,
        hasReachedMax: false,
        auctions: [],
      ),
    );
    loadAuctions();
  }

  Future<void> loadAuctions() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final newAuctions = await _repository.getLiveAuctions(
        category: state.category,
        condition: state.condition,
        sortBy: state.sortBy,
        page: state.page,
        limit: 20,
      );

      final now = DateTime.now();
      final filtered = newAuctions.where((a) {
        // Never surface ended auctions — not requested by user
        if (a.status == 'ended') return false;
        // Also exclude auctions whose endTime has already passed
        if (a.endTime != null && a.endTime!.isBefore(now)) return false;

        if (state.filterStatus == 'live') {
          return a.status == 'live' || a.status == 'active';
        }
        if (state.filterStatus == 'upcoming') {
          return a.status == 'upcoming';
        }
        return true;
      }).toList();

      // local sort since backend might not support all sort queries yet
      if (state.sortBy == 'price_asc') {
        filtered.sort((a, b) => (a.currentPrice ?? a.startPrice ?? 0).compareTo(b.currentPrice ?? b.startPrice ?? 0));
      } else if (state.sortBy == 'price_desc') {
        filtered.sort((a, b) => (b.currentPrice ?? b.startPrice ?? 0).compareTo(a.currentPrice ?? a.startPrice ?? 0));
      } else if (state.sortBy == 'ending_soon') {
        filtered.sort((a, b) => (a.endTime ?? DateTime.now()).compareTo(b.endTime ?? DateTime.now()));
      }

      emit(
        state.copyWith(
          isLoading: false,
          auctions: state.page == 1
              ? filtered
              : [...state.auctions, ...filtered],
          hasReachedMax: newAuctions.length < 20,
        ),
      );
    } catch (e, st) {
      LogService().error('Failed to load auctions', e, st);
      emit(state.copyWith(isLoading: false, error: 'Failed to load auctions.'));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasReachedMax) return;
    emit(state.copyWith(page: state.page + 1));
    await loadAuctions();
  }

  /// Load the current user's bid history (won / lost / pending).
  Future<void> loadMyBids() async {
    emit(state.copyWith(isLoadingMyBids: true));
    try {
      final bids = await _repository.getMyBids();
      emit(state.copyWith(isLoadingMyBids: false, myBids: bids));
    } catch (e, st) {
      LogService().error('Failed to load my bids', e, st);
      emit(state.copyWith(isLoadingMyBids: false));
    }
  }

  /// Load auctions the user is watching.
  Future<void> loadWatchedAuctions() async {
    emit(state.copyWith(isLoadingWatchlist: true));
    try {
      final watched = await _repository.getWatchedAuctions();
      emit(state.copyWith(isLoadingWatchlist: false, watchedAuctions: watched));
    } catch (e, st) {
      LogService().error('Failed to load watchlist', e, st);
      emit(state.copyWith(isLoadingWatchlist: false));
    }
  }
}
