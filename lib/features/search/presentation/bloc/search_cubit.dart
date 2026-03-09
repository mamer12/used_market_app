import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/repositories/search_repository.dart';

part 'search_cubit.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.success(List<dynamic> results) = _Success;
  const factory SearchState.error(String message) = _Error;
}

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;

  // A subject to handle debouncing of search queries
  final _querySubject = PublishSubject<String>();

  SearchCubit(this._searchRepository) : super(const SearchState.initial()) {
    _querySubject
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .listen((query) {
          _performSearch(query);
        });
  }

  void onQueryChanged(String query) {
    if (query.isEmpty) {
      emit(const SearchState.initial());
      return;
    }
    emit(const SearchState.loading());
    _querySubject.add(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchRepository.search(query);
      emit(SearchState.success(results));
    } catch (e) {
      emit(SearchState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _querySubject.close();
    return super.close();
  }
}
