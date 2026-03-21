import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/group_buy_model.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class GroupBuyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupBuyInitial extends GroupBuyState {}

class GroupBuyLoading extends GroupBuyState {}

class GroupBuyLoaded extends GroupBuyState {
  final GroupBuyModel groupBuy;

  GroupBuyLoaded(this.groupBuy);

  @override
  List<Object?> get props => [groupBuy];
}

class GroupBuyJoined extends GroupBuyState {
  final GroupBuyModel groupBuy;

  GroupBuyJoined(this.groupBuy);

  @override
  List<Object?> get props => [groupBuy];
}

class GroupBuyError extends GroupBuyState {
  final String message;

  GroupBuyError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class GroupBuyCubit extends Cubit<GroupBuyState> {
  final Dio _dio;

  GroupBuyCubit(this._dio) : super(GroupBuyInitial());

  Future<void> fetchGroupBuy(String id) async {
    emit(GroupBuyLoading());
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('group-buys/$id');
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
        emit(GroupBuyLoaded(GroupBuyModel.fromJson(data)));
      } else {
        emit(GroupBuyError('فشل تحميل الشلة'));
      }
    } on DioException catch (e) {
      emit(GroupBuyError(e.message ?? 'حدث خطأ'));
    }
  }

  Future<void> joinGroupBuy(String id) async {
    emit(GroupBuyLoading());
    try {
      final res =
          await _dio.post<Map<String, dynamic>>('group-buys/$id/join');
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data != null) {
        final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
        emit(GroupBuyJoined(GroupBuyModel.fromJson(data)));
      } else {
        emit(GroupBuyError('فشل الانضمام إلى الشلة'));
      }
    } on DioException catch (e) {
      emit(GroupBuyError(e.message ?? 'حدث خطأ'));
    }
  }

  Future<GroupBuyModel?> createGroupBuy(String productId) async {
    emit(GroupBuyLoading());
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        'group-buys',
        data: {'product_id': productId},
      );
      if (res.statusCode == 201 && res.data != null) {
        final data = res.data!['data'] as Map<String, dynamic>? ?? res.data!;
        final model = GroupBuyModel.fromJson(data);
        emit(GroupBuyLoaded(model));
        return model;
      } else {
        emit(GroupBuyError('فشل إنشاء الشلة'));
        return null;
      }
    } on DioException catch (e) {
      emit(GroupBuyError(e.message ?? 'حدث خطأ'));
      return null;
    }
  }
}
