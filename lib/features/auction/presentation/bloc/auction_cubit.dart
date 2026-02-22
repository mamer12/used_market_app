import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../data/models/auction_models.dart';
import '../../domain/repositories/auction_repository.dart';

// ── State ────────────────────────────────────────────────────────────────
class AuctionState {
  final bool isLoading;
  final AuctionModel? auction;
  final List<BidModel> bids;
  final String? error;

  const AuctionState({
    this.isLoading = false,
    this.auction,
    this.bids = const [],
    this.error,
  });

  AuctionState copyWith({
    bool? isLoading,
    AuctionModel? auction,
    List<BidModel>? bids,
    String? error,
  }) {
    return AuctionState(
      isLoading: isLoading ?? this.isLoading,
      auction: auction ?? this.auction,
      bids: bids ?? this.bids,
      error: error ?? this.error,
    );
  }
}

// ── Cubit ────────────────────────────────────────────────────────────────
@injectable
class AuctionCubit extends Cubit<AuctionState> {
  final AuctionRepository _repository;

  StreamSubscription? _bidSubscription;
  StreamSubscription? _errorSubscription;

  AuctionCubit(this._repository) : super(const AuctionState());

  /// Loads initial auction details, historical bids, and connects to WS
  Future<void> initAuctionLive(String auctionId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // 1. Fetch historical details
      final results = await Future.wait([
        _repository.getAuctionDetails(auctionId),
        _repository.getBidHistory(auctionId, limit: 100),
      ]);

      final auction = results[0] as AuctionModel;
      final historyBids = results[1] as List<BidModel>;

      emit(
        state.copyWith(isLoading: false, auction: auction, bids: historyBids),
      );

      // 2. Connect to WS
      await _repository.connectToAuction(auctionId);

      // 3. Listen to live events
      _bidSubscription = _repository.liveBidStream.listen((event) {
        // Insert at end (or beginning, depending on UI sorting)
        final updatedBids = List<BidModel>.from(state.bids)..add(event.bid);
        final updatedAuction = state.auction?.copyWith(
          currentPrice: event.currentPrice,
        );
        emit(state.copyWith(bids: updatedBids, auction: updatedAuction));
      });

      _errorSubscription = _repository.auctionErrorStream.listen((errorMsg) {
        LogService().error('Live Auction WS Error: $errorMsg');
        // We might not want to disrupt the whole UI if a WS error occurs,
        // maybe just show a snackbar (which listeners can handle if we emit an error state).
      });
    } catch (e, st) {
      LogService().error('Failed to init Auction Live', e, st);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load live auction data.',
        ),
      );
    }
  }

  /// Places a bid via:
  ///   1. REST API (POST /auctions/{id}/bids) — authoritative, returns the
  ///      confirmed `BidModel` with server-assigned id.
  ///   2. WebSocket — broadcasts the bid to all connected viewers in real-time.
  ///
  /// If the REST call fails (e.g. bid too low) an error state is emitted.
  void placeBid(int amount) {
    if (state.auction == null || state.auction!.id == null) return;

    // Optimistically add to UI immediately
    final optimisticBid = BidModel(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      bidderId: 'me',
      amount: amount,
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(bids: [...state.bids, optimisticBid]));

    // REST — primary confirmation
    _repository
        .placeBid(state.auction!.id!, PlaceBidRequest(amount: amount))
        .then((confirmedBid) {
          // Replace optimistic entry with confirmed one
          final updated =
              state.bids.where((b) => b.id != optimisticBid.id).toList()
                ..add(confirmedBid);
          emit(state.copyWith(bids: updated));
        })
        .catchError((Object e) {
          // Roll back optimistic bid and surface the error
          final rolled = state.bids
              .where((b) => b.id != optimisticBid.id)
              .toList();
          LogService().error('Failed to place bid', e);
          emit(state.copyWith(bids: rolled, error: e.toString()));
        });

    // WS — real-time propagation to other viewers
    _repository.placeRealTimeBid(amount.toDouble());
  }

  @override
  Future<void> close() {
    _bidSubscription?.cancel();
    _errorSubscription?.cancel();
    _repository.disconnectFromAuction();
    return super.close();
  }
}
