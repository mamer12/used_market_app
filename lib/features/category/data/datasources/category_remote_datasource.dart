import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({
    required String appContext,
    String? parentId,
  });
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories({
    required String appContext,
    String? parentId,
  }) async {
    final queryParameters = <String, dynamic>{'app_context': appContext};
    if (parentId != null) {
      queryParameters['parent_id'] = parentId;
    } else {
      queryParameters['parent_id'] = 'null';
    }

    final response = await _dio.get(
      '/categories',
      queryParameters: queryParameters,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
