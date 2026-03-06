import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/media_response.dart';

abstract class MediaRemoteDataSource {
  /// Upload a single file. Returns the CDN URL of the uploaded media.
  Future<MediaResponse> uploadMedia(File file);

  /// Upload multiple files in parallel.
  /// Returns a list of CDN URLs in the same order as [files].
  /// Individual failures throw, so wrap in try/catch at call-site.
  Future<List<String>> uploadImages(List<File> files);
}

@LazySingleton(as: MediaRemoteDataSource)
class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final Dio _dio;

  MediaRemoteDataSourceImpl(this._dio);

  @override
  Future<MediaResponse> uploadMedia(File file) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post(ApiConstants.mediaUpload, data: formData);

    return MediaResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<String>> uploadImages(List<File> files) async {
    // Upload all files in parallel for speed.
    final responses = await Future.wait(files.map((f) => uploadMedia(f)));
    return responses.map((r) => r.url).toList();
  }
}
