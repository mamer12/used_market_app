import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/group_buy_model.dart';
import '../../domain/repositories/group_buy_repository.dart';

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

@injectable
class GroupBuyCubit extends Cubit<GroupBuyState> {
  final GroupBuyRepository _repository;

  GroupBuyCubit(this._repository) : super(GroupBuyInitial());

  Future<void> fetchGroupBuy(String id) async {
    emit(GroupBuyLoading());
    try {
      final groupBuy = await _repository.getGroupBuy(id);
      emit(GroupBuyLoaded(groupBuy));
    } catch (e) {
      emit(GroupBuyError(e.toString()));
    }
  }

  Future<void> joinGroupBuy(String id) async {
    emit(GroupBuyLoading());
    try {
      final groupBuy = await _repository.joinGroupBuy(id);
      emit(GroupBuyJoined(groupBuy));
    } catch (e) {
      emit(GroupBuyError(e.toString()));
    }
  }

  Future<GroupBuyModel?> createGroupBuy(String productId) async {
    emit(GroupBuyLoading());
    try {
      final model = await _repository.createGroupBuy(productId);
      emit(GroupBuyLoaded(model));
      return model;
    } catch (e) {
      emit(GroupBuyError(e.toString()));
      return null;
    }
  }
}
