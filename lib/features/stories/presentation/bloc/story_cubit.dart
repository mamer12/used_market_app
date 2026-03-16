import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/story_model.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class StoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoriesLoaded extends StoryState {
  final List<StoryGroupModel> groups;

  StoriesLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class StoryError extends StoryState {
  final String message;

  StoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class StoryCubit extends Cubit<StoryState> {
  final Dio _dio;

  StoryCubit(this._dio) : super(StoryInitial());

  Future<void> fetchFeed() async {
    emit(StoryLoading());
    try {
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

      final groups = grouped.values.toList()
        ..sort(
            (a, b) => (b.hasUnwatched ? 1 : 0) - (a.hasUnwatched ? 1 : 0));
      emit(StoriesLoaded(groups));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> markViewed(String storyId) async {
    try {
      await _dio.post('/api/v1/stories/$storyId/view');
    } catch (_) {}
  }
}
