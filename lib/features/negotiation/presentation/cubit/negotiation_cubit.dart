import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/negotiation_model.dart';

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

class NegotiationCubit extends Cubit<NegotiationState> {
  final String baseUrl;
  final String token;
  late final Dio _dio;

  NegotiationCubit({required this.baseUrl, required this.token})
      : super(NegotiationInitial()) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      validateStatus: (_) => true,
    ));
  }

  Future<void> fetchMyNegotiations() async {
    emit(NegotiationLoading());
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          '/api/v1/negotiations/mine');
      if (res.statusCode == 200) {
        final data = (res.data?['data'] as List?) ?? [];
        emit(NegotiationLoaded(
          data
              .map((e) => NegotiationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ));
      } else {
        emit(NegotiationError('فشل تحميل العروض'));
      }
    } on DioException catch (e) {
      emit(NegotiationError(e.message ?? 'حدث خطأ'));
    }
  }

  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  }) async {
    try {
      final res = await _dio.post<void>(
        '/api/v1/negotiations',
        data: {'product_id': productId, 'offered_price': offeredPrice},
      );
      return res.statusCode == 201;
    } on DioException {
      return false;
    }
  }

  Future<bool> acceptNegotiation(String id) async {
    try {
      final res =
          await _dio.patch<void>('/api/v1/negotiations/$id/accept');
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<bool> counterNegotiation(String id, int counterPrice) async {
    try {
      final res = await _dio.patch<void>(
        '/api/v1/negotiations/$id/counter',
        data: {'counter_price': counterPrice},
      );
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<bool> rejectNegotiation(String id) async {
    try {
      final res =
          await _dio.patch<void>('/api/v1/negotiations/$id/reject');
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}
