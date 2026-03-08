import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryModel>> getCategories({
    required String appContext,
    String? parentId,
  }) async {
    try {
      final categories = await remoteDataSource.getCategories(
        appContext: appContext,
        parentId: parentId,
      );
      return categories;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['error'] ?? 'Failed to load categories',
        );
      }
      throw Exception('Connection error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
