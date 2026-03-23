import 'package:injectable/injectable.dart';

import '../../domain/repositories/story_repository.dart';
import '../datasources/story_remote_data_source.dart';
import '../models/story_model.dart';

@LazySingleton(as: StoryRepository)
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;

  StoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<StoryGroupModel>> getStoryFeed() =>
      _remoteDataSource.getStoryFeed();

  @override
  Future<void> markViewed(String storyId) =>
      _remoteDataSource.markViewed(storyId);
}
