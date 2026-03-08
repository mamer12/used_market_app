import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/category_model.dart';

part 'category_state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = CategoryStateInitial;
  const factory CategoryState.loading() = CategoryStateLoading;
  const factory CategoryState.loaded({
    required List<CategoryModel> categories,
    String? currentParentId,
    @Default([]) List<String?> parentIdStack,
  }) = CategoryStateLoaded;
  const factory CategoryState.error(String message) = CategoryStateError;
}
