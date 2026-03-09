import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';

abstract class SearchRemoteDataSource {
  Future<List<dynamic>> search(String query);
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl(this._dio);

  @override
  Future<List<dynamic>> search(String query) async {
    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: {'q': query},
    );
    return response.data as List<dynamic>;
  }
}
