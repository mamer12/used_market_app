import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shop_models.dart';
import '../../domain/repositories/shop_repository.dart';

enum CreateShopStatus { initial, loading, success, error }

class CreateShopState {
  final CreateShopStatus status;
  final String? error;

  const CreateShopState({this.status = CreateShopStatus.initial, this.error});

  CreateShopState copyWith({CreateShopStatus? status, String? error}) {
    return CreateShopState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

@injectable
class CreateShopCubit extends Cubit<CreateShopState> {
  final ShopRepository _shopRepository;

  CreateShopCubit(this._shopRepository) : super(const CreateShopState());

  Future<void> createShop(CreateShopRequest request) async {
    emit(state.copyWith(status: CreateShopStatus.loading));
    try {
      await _shopRepository.createShop(request);
      emit(state.copyWith(status: CreateShopStatus.success));
    } catch (e) {
      emit(state.copyWith(status: CreateShopStatus.error, error: e.toString()));
    }
  }
}
