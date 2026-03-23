import '../../data/models/story_model.dart';

abstract class StoryRepository {
  Future<List<StoryGroupModel>> getStoryFeed();
  Future<void> markViewed(String storyId);
}
