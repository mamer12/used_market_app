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
  // Live bidding flow states
  final bool isOutbid;
  final bool isWon;
  final bool isBidPlacing;
  final int? myLastBid;
  final int? finalPrice;
  final String? winnerId;

  const AuctionState({
    this.isLoading = false,
    this.auction,
    this.bids = const [],
    this.error,
    this.isOutbid = false,
    this.isWon = false,
    this.isBidPlacing = false,
    this.myLastBid,
    this.finalPrice,
    this.winnerId,
  });

  AuctionState copyWith({
    bool? isLoading,
    AuctionModel? auction,
    List<BidModel>? bids,
    String? error,
    bool? isOutbid,
    bool? isWon,
    bool? isBidPlacing,
    int? myLastBid,
    int? finalPrice,
    String? winnerId,
  }) {
    return AuctionState(
      isLoading: isLoading ?? this.isLoading,
      auction: auction ?? this.auction,
      bids: bids ?? this.bids,
      error: error ?? this.error,
      isOutbid: isOutbid ?? this.isOutbid,
      isWon: isWon ?? this.isWon,
      isBidPlacing: isBidPlacing ?? this.isBidPlacing,
      myLastBid: myLastBid ?? this.myLastBid,
      finalPrice: finalPrice ?? this.finalPrice,
      winnerId: winnerId ?? this.winnerId,
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
      final results = await Future.wait([
        _repository.getAuctionDetails(auctionId),
        _repository.getBidHistory(auctionId, limit: 100),
      ]);

      final auction = results[0] as AuctionModel;
      final historyBids = results[1] as List<BidModel>;

      emit(
        state.copyWith(isLoading: false, auction: auction, bids: historyBids),
      );

      await _repository.connectToAuction(auctionId);

      _bidSubscription = _repository.liveBidStream.listen((event) {
        final updatedBids = List<BidModel>.from(state.bids)..add(event.bid);
        final updatedAuction = state.auction?.copyWith(
          currentPrice: event.currentPrice,
        );

        // If someone else outbid us (event.bid is not 'me') and we had a bid
        final bool outbid =
            state.myLastBid != null &&
            event.bid.bidderId != 'me' &&
            event.bid.amount > (state.myLastBid ?? 0);

        emit(
          state.copyWith(
            bids: updatedBids,
            auction: updatedAuction,
            isOutbid: outbid,
          ),
        );
      });

      _errorSubscription = _repository.auctionErrorStream.listen((msg) {
        LogService().error('Live Auction WS Error: $msg');
      });

      // Listen for auction ended event
      _repository.liveBidStream.listen((_) {}).onDone(() {
        if (state.auction?.status == 'ended') {
          emit(state.copyWith(isWon: state.auction?.winnerId == 'me'));
        }
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

  /// Clears the outbid flag (e.g. when user dismisses the overlay)
  void clearOutbid() => emit(state.copyWith(isOutbid: false));

  /// Places a bid with optimistic UI + REST confirmation
  void placeBid(int amount) {
    if (state.auction == null || state.auction!.id == null) return;

    emit(state.copyWith(isBidPlacing: true, error: null));

    final optimisticBid = BidModel(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      bidderId: 'me',
      amount: amount,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        bids: [...state.bids, optimisticBid],
        myLastBid: amount,
        isOutbid: false,
      ),
    );

    _repository
        .placeBid(state.auction!.id!, PlaceBidRequest(amount: amount))
        .then((confirmedBid) {
          final updated =
              state.bids.where((b) => b.id != optimisticBid.id).toList()
                ..add(confirmedBid);
          emit(state.copyWith(bids: updated, isBidPlacing: false));
        })
        .catchError((Object e) {
          final rolled = state.bids
              .where((b) => b.id != optimisticBid.id)
              .toList();
          LogService().error('Failed to place bid', e);
          emit(
            state.copyWith(
              bids: rolled,
              error: e.toString(),
              isBidPlacing: false,
            ),
          );
        });

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
