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
}
