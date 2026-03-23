import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/negotiation_model.dart';
import '../../domain/repositories/negotiation_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class NegotiationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NegotiationInitial extends NegotiationState {}

class NegotiationLoading extends NegotiationState {}

class NegotiationLoaded extends NegotiationState {
  final List<NegotiationModel> negotiations;

  NegotiationLoaded(this.negotiations);

  @override
  List<Object?> get props => [negotiations];
}

class NegotiationSuccess extends NegotiationState {
  final String message;

  NegotiationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NegotiationError extends NegotiationState {
  final String message;

  NegotiationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class NegotiationCubit extends Cubit<NegotiationState> {
  final NegotiationRepository _repository;

  NegotiationCubit(this._repository) : super(NegotiationInitial());

  Future<void> fetchMyNegotiations() async {
    emit(NegotiationLoading());
    try {
      final negotiations = await _repository.getNegotiations();
      emit(NegotiationLoaded(negotiations));
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }

  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  }) async {
    try {
      return await _repository.submitOffer(
          productId: productId, offeredPrice: offeredPrice);
    } catch (_) {
      return false;
    }
  }

  Future<bool> acceptNegotiation(String id) async {
    try {
      return await _repository.acceptNegotiation(id);
    } catch (_) {
      return false;
    }
  }

  Future<bool> counterNegotiation(String id, int counterPrice) async {
    try {
      return await _repository.counterNegotiation(id, counterPrice);
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectNegotiation(String id) async {
    try {
      return await _repository.rejectNegotiation(id);
    } catch (_) {
      return false;
    }
  }
}
