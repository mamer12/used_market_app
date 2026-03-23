import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<List<StoryGroupModel>> getStoryFeed();
  Future<void> markViewed(String storyId);
}

@LazySingleton(as: StoryRemoteDataSource)
class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio _dio;

  StoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<StoryGroupModel>> getStoryFeed() async {
    final resp = await _dio.get('/api/v1/stories/feed');
    final raw = (resp.data['data'] as List?) ?? [];

    final Map<String, StoryGroupModel> grouped = {};
    for (final item in raw) {
      final m = item as Map<String, dynamic>;
      final shopId = m['shop_id'] as String;
      if (!grouped.containsKey(shopId)) {
        grouped[shopId] = StoryGroupModel(
          shopId: shopId,
          shopName: m['shop_name'] as String? ?? '',
          shopLogoUrl: m['shop_logo_url'] as String? ?? '',
          sooqContext: m['sooq_context'] as String? ?? 'matajir',
          stories: const [],
          hasUnwatched: false,
        );
      }
      final story = StoryItemModel.fromJson(m);
      final existing = grouped[shopId]!;
      grouped[shopId] = StoryGroupModel(
        shopId: existing.shopId,
        shopName: existing.shopName,
        shopLogoUrl: existing.shopLogoUrl,
        sooqContext: existing.sooqContext,
        stories: [...existing.stories, story],
        hasUnwatched: existing.hasUnwatched || !story.isWatched,
      );
    }

    return grouped.values.toList()
      ..sort((a, b) => (b.hasUnwatched ? 1 : 0) - (a.hasUnwatched ? 1 : 0));
  }

  @override
  Future<void> markViewed(String storyId) async {
    await _dio.post('/api/v1/stories/$storyId/view');
  }
}
