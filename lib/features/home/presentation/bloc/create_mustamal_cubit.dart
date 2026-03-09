import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../media/data/datasources/media_remote_data_source.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/domain/repositories/shop_repository.dart';

part 'create_mustamal_cubit.freezed.dart';

@freezed
class CreateMustamalState with _$CreateMustamalState {
  const factory CreateMustamalState.initial() = _Initial;
  const factory CreateMustamalState.loading() = _Loading;
  const factory CreateMustamalState.success(ProductModel item) = _Success;
  const factory CreateMustamalState.error(String message) = _Error;
}

@injectable
class CreateMustamalCubit extends Cubit<CreateMustamalState> {
  final ShopRepository _shopRepository;
  final MediaRemoteDataSource _mediaDataSource;

  CreateMustamalCubit(this._shopRepository, this._mediaDataSource)
    : super(const CreateMustamalState.initial());

  Future<void> submit({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required String condition,
    required String city,
    required List<File> localImages,
  }) async {
    emit(const CreateMustamalState.loading());
    try {
      // 1. Upload images to CDN
      final imageUrls = await _mediaDataSource.uploadImages(localImages);

      // 2. Create the listing
      final request = CreateMustamalRequest(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: condition,
        city: city,
        images: imageUrls,
      );

      final result = await _shopRepository.createMustamalListing(request);
      emit(CreateMustamalState.success(result));
    } catch (e) {
      emit(CreateMustamalState.error(e.toString()));
    }
  }
}
