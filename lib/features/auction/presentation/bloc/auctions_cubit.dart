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

      // Locally apply 'status' filter conceptually here or rely on BE.
      // Since backend doesn't take 'status' in getAuctions as per instructions (wait, it didn't list it),
      // we filter locally if it has both. Or we assume BE returns them properly and we filter.
      // Actually, if we just want to match the previous local filter behavior:
      final filtered = newAuctions.where((a) {
        if (state.filterStatus == 'live') return a.status == 'live';
        if (state.filterStatus == 'upcoming') return a.status == 'upcoming';
        if (state.filterStatus == 'ended') return a.status == 'ended';
        return true;
      }).toList();

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
}
