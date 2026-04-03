import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/flash_drop_model.dart';
import '../../domain/repositories/flash_drop_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class FlashDropState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashDropInitial extends FlashDropState {}

class FlashDropLoading extends FlashDropState {}

class FlashDropsLoaded extends FlashDropState {
  final List<FlashDropModel> drops;

  FlashDropsLoaded(this.drops);

  @override
  List<Object?> get props => [drops];
}

class FlashDropError extends FlashDropState {
  final String message;

  FlashDropError(this.message);

  @override
  List<Object?> get props => [message];
}

class FlashDropPurchasing extends FlashDropState {
  final String flashDropId;

  FlashDropPurchasing(this.flashDropId);

  @override
  List<Object?> get props => [flashDropId];
}

class FlashDropPurchaseSuccess extends FlashDropState {
  final String orderId;
  final String flashDropId;

  FlashDropPurchaseSuccess({required this.orderId, required this.flashDropId});

  @override
  List<Object?> get props => [orderId, flashDropId];
}

class FlashDropPurchaseError extends FlashDropState {
  final String message;
  final String flashDropId;

  FlashDropPurchaseError({required this.message, required this.flashDropId});

  @override
  List<Object?> get props => [message, flashDropId];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class FlashDropCubit extends Cubit<FlashDropState> {
  final FlashDropRepository _repository;
  Timer? _pollTimer;

  FlashDropCubit(this._repository) : super(FlashDropInitial());

  Future<void> fetchActive() async {
    emit(FlashDropLoading());
    try {
      final drops = await _repository.getActiveFlashDrops();
      emit(FlashDropsLoaded(drops.where((d) => !d.isExpired).toList()));
    } catch (e) {
      emit(FlashDropError(e.toString()));
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      fetchActive();
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  /// Purchase a flash drop item.
  /// Emits [FlashDropPurchasing] while loading,
  /// then [FlashDropPurchaseSuccess] or [FlashDropPurchaseError].
  Future<void> purchaseFlashDrop(String flashDropId) async {
    emit(FlashDropPurchasing(flashDropId));
    try {
      final orderId = await _repository.purchaseFlashDrop(flashDropId);
      emit(FlashDropPurchaseSuccess(orderId: orderId, flashDropId: flashDropId));
      // Re-fetch active drops to update stock
      await fetchActive();
    } catch (e) {
      emit(FlashDropPurchaseError(
        message: e.toString(),
        flashDropId: flashDropId,
      ));
    }
  }
}
