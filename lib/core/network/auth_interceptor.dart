import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final dataMap = response.data as Map<String, dynamic>;
      // If the backend returns our standard success wrapper, peel it off
      if (dataMap.containsKey('success') && dataMap['success'] == true) {
        // Only re-assign data if the 'data' key actually exists
        if (dataMap.containsKey('data')) {
          response.data = dataMap['data'];
        } else {
          // Success but no data payload
          response.data = null;
        }
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Standardize error handling from Lugta API.
    // The API uses `{"success": false, "error": "message"}`
    if (err.response?.data != null &&
        err.response?.data is Map<String, dynamic>) {
      final errorMap = err.response!.data as Map<String, dynamic>;
      if (errorMap.containsKey('error')) {
        final errorMessage = errorMap['error'] as String;
        // Transform the DioException to our custom error to be caught by repositories.
        final newErr = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException(
            errorMessage,
            statusCode: err.response?.statusCode,
          ),
        );
        return handler.next(newErr);
      }
    }

    // Fallback if the error format isn't what we expect
    final defaultErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ApiException(
        'An unexpected error occurred',
        statusCode: err.response?.statusCode,
      ),
    );
    handler.next(defaultErr);
  }
}
