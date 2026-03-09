import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../media/data/datasources/media_remote_data_source.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/domain/repositories/shop_repository.dart';

part 'create_balla_cubit.freezed.dart';

@freezed
class CreateBallaState with _$CreateBallaState {
  const factory CreateBallaState.initial() = _Initial;
  const factory CreateBallaState.loading() = _Loading;
  const factory CreateBallaState.success(ProductModel item) = _Success;
  const factory CreateBallaState.error(String message) = _Error;
}

@injectable
class CreateBallaCubit extends Cubit<CreateBallaState> {
  final ShopRepository _shopRepository;
  final MediaRemoteDataSource _mediaDataSource;

  CreateBallaCubit(this._shopRepository, this._mediaDataSource)
    : super(const CreateBallaState.initial());

  Future<void> submit({
    required String shopId,
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required String condition,
    required String salesUnit,
    required String city,
    required double weight,
    required List<File> localImages,
  }) async {
    emit(const CreateBallaState.loading());
    try {
      // 1. Upload images
      final imageUrls = await _mediaDataSource.uploadImages(localImages);

      // 2. Create Balla Listing
      final request = CreateBallaRequest(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: condition,
        city: city,
        images: imageUrls,
        salesUnit: salesUnit,
        weight: weight,
      );

      final result = await _shopRepository.createBallaListing(shopId, request);
      emit(CreateBallaState.success(result));
    } catch (e) {
      emit(CreateBallaState.error(e.toString()));
    }
  }
}
