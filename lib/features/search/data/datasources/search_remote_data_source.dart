import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/search_models.dart';

abstract class SearchRemoteDataSource {
  /// Calls GET /search?q=[query].
  ///
  /// Throws a [DioException] on network errors.
  /// Returns [SearchResponse.empty] when the query is blank (caller should
  /// guard against this before calling).
  Future<SearchResponse> search(String query);
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl(this._dio);

  @override
  Future<SearchResponse> search(String query) async {
    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: {'q': query},
    );
    return SearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
