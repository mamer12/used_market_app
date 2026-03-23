import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/story_model.dart';
import '../../domain/repositories/story_repository.dart';

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
  final StoryRepository _repository;

  StoryCubit(this._repository) : super(StoryInitial());

  Future<void> fetchFeed() async {
    emit(StoryLoading());
    try {
      final groups = await _repository.getStoryFeed();
      emit(StoriesLoaded(groups));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> markViewed(String storyId) async {
    try {
      await _repository.markViewed(storyId);
    } catch (_) {}
  }
}
