import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/flash_drop_model.dart';

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
  final Dio _dio;
  Timer? _pollTimer;

  FlashDropCubit(this._dio) : super(FlashDropInitial());

  Future<void> fetchActive() async {
    emit(FlashDropLoading());
    try {
      final resp = await _dio.get('/api/v1/flash-drops/active');
      final raw = (resp.data['data'] as List?) ?? [];
      final drops = raw
          .map((e) => FlashDropModel.fromJson(e as Map<String, dynamic>))
          .where((d) => !d.isExpired)
          .toList();
      emit(FlashDropsLoaded(drops));
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
