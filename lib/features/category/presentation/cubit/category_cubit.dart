import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/category_repository.dart';
import 'category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;
  final String appContext;

  CategoryCubit({
    required this.repository,
    @factoryParam required this.appContext,
  }) : super(const CategoryState.initial());

  Future<void> fetchCategories({
    String? parentId,
    bool isNavigatingBack = false,
  }) async {
    List<String?> stack = [];
    final currentState = state;

    if (currentState is CategoryStateLoaded) {
      if (!isNavigatingBack) {
        // Pushing a new parent
        stack = List<String?>.from(currentState.parentIdStack);
        stack.add(currentState.currentParentId);
      } else {
        // Popping a parent
        stack = List<String?>.from(currentState.parentIdStack);
        if (stack.isNotEmpty) {
          parentId = stack.removeLast();
        }
      }
    }

    emit(const CategoryState.loading());

    try {
      final categories = await repository.getCategories(
        appContext: appContext,
        parentId: parentId,
      );
      emit(
        CategoryState.loaded(
          categories: categories,
          currentParentId: parentId,
          parentIdStack: stack,
        ),
      );
    } catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }

  void drillDown(String parentId) {
    fetchCategories(parentId: parentId);
  }

  void navigateBack() {
    fetchCategories(isNavigatingBack: true);
  }
}
