import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/flash_drop_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class FlashDropCreateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashDropCreateInitial extends FlashDropCreateState {}

class FlashDropCreateLoading extends FlashDropCreateState {}

class FlashDropCreateSuccess extends FlashDropCreateState {}

class FlashDropCreateError extends FlashDropCreateState {
  final String message;

  FlashDropCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class FlashDropCreateCubit extends Cubit<FlashDropCreateState> {
  final FlashDropRepository _repository;

  FlashDropCreateCubit(this._repository) : super(FlashDropCreateInitial());

  Future<void> createFlashDrop({
    required String productId,
    required int discountPct,
    required int slots,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    emit(FlashDropCreateLoading());
    try {
      await _repository.createFlashDrop(
        productId: productId,
        discountPct: discountPct,
        slots: slots,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      emit(FlashDropCreateSuccess());
    } catch (e) {
      emit(FlashDropCreateError(e.toString()));
    }
  }
}
