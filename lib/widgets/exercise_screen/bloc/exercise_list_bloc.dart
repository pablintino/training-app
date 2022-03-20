import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'exercise_list_event.dart';

part 'exercise_list_state.dart';

class ExerciseListBloc extends Bloc<ExerciseListEvent, ExerciseListState> {
  final ExercisesRepository _exercisesRepository;

  bool get isFetching => state is ExerciseListLoadingState;

  ExerciseListBloc()
      : _exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(ExerciseListState()) {
    on<ExercisesFetchEvent>((_, emit) => _handleFetchEvent(emit));
    on<ModifiedOrCreatedExerciseEvent>(
        (event, emit) => _handleListModificationEvent(event, emit));
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit),
        transformer: _debounceRestartable(const Duration(milliseconds: 500)));
  }

  Future<void> _handleFetchEvent(Emitter emit) async {
    emit(ExerciseListLoadingState.fromState(state));
    final pageNumber =
        (state.exercises.length / ExercisesRepository.PAGE_SIZE).truncate();
    await _exercisesRepository
        .getExercisesByPage(pageNumber, state.searchFilter)
        .then((retrievedExercises) {
      List<Exercise> exercises = List.from(state.exercises)
        ..addAll(_removeExistingExercises(state, retrievedExercises));
      emit(ExerciseListLoadingState.fromState(state, exercises: exercises));
    }).catchError((err) {
      emit(ExerciseListErrorState.fromState(state, err.toString()));
    });
  }

  Future<void> _handleListModificationEvent(
      ModifiedOrCreatedExerciseEvent event, Emitter emit) async {
    if (event.exercise.id != null) {
      int index = state.exercises
          .indexWhere((element) => element.id == event.exercise.id);
      List<Exercise> exercises = List.from(state.exercises);
      if (index >= 0) {
        exercises[index] = event.exercise;
        emit(ExerciseListItemModifiedState.fromState(state, index));
      } else {
        exercises.add(event.exercise);
        // On client sort of the new list after appending
        exercises.sort((a, b) =>
            a.name != null && b.name != null ? a.name!.compareTo(b.name!) : 0);
        emit(ExerciseListItemModifiedState.fromState(state,
            exercises.indexWhere((element) => element.id == event.exercise.id),
            exercises: exercises));
      }
    }
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    final filter = (event.filter ?? '').isEmpty ? null : event.filter;
    // Reset the whole state
    emit(ExerciseListLoadingState.fromState(state));

    await _exercisesRepository
        .getExercisesByPage(0, filter)
        .then((retrievedExercises) {
      List<Exercise> exercises = List.from(state.exercises)
        ..addAll(_removeExistingExercises(state, retrievedExercises));
      emit(ExerciseListLoadingState.fromState(state,
          searchFilter: filter, exercises: exercises));
    }).catchError((err) {
      emit(ExerciseListErrorState.fromState(state, err.toString()));
    });
  }

  static List<Exercise> _removeExistingExercises(
      ExerciseListState state, final List<Exercise> list) {
    return list.where((element) => !state.exercises.contains(element)).toList();
  }

  EventTransformer<ExerciseListEvent> _debounceRestartable<ExerciseListEvent>(
    Duration duration,
  ) {
    // This feeds the debounced event stream to restartable() and returns that
    // as a transformer.
    return (events, mapper) => restartable<ExerciseListEvent>()
        .call(events.debounceTime(duration), mapper);
  }
}
