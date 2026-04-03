import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/feed_models.dart';

@injectable
class FeedRemoteDataSource {
  final Dio _dio;

  const FeedRemoteDataSource(this._dio);

  /// Fetches the personalized "for you" feed.
  Future<PersonalizedFeedResponse> getForYouFeed() async {
    final response = await _dio.get(ApiConstants.feedForYou);
    final data = response.data as Map<String, dynamic>;
    return PersonalizedFeedResponse.fromJson(data);
  }

  /// Posts a feed interaction event for personalization.
  Future<void> trackEvent({
    required String eventType,
    required String entityType,
    required String entityId,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{
      'event_type': eventType,
      'entity_type': entityType,
      'entity_id': entityId,
      'category_id': categoryId,
    };
    await _dio.post(ApiConstants.feedEvent, data: body);
  }
}
