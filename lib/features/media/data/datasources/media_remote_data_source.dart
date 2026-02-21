import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/media_response.dart';

abstract class MediaRemoteDataSource {
  Future<MediaResponse> uploadMedia(File file);
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
}
