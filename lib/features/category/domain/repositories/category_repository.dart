import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories({
    required String appContext,
    String? parentId,
  });
}
