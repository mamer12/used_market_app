import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_response.freezed.dart';
part 'media_response.g.dart';

@freezed
abstract class MediaResponse with _$MediaResponse {
  const factory MediaResponse({required String url}) = _MediaResponse;

  factory MediaResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaResponseFromJson(json);
}
