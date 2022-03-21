import 'dart:async';

import 'package:bloc/bloc.dart';
import "package:collection/collection.dart";
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/utils/streams.dart';

part 'exercise_list_event.dart';

part 'exercise_list_state.dart';

class ExerciseListBloc extends Bloc<ExerciseListEvent, ExerciseListState> {
  final ExercisesRepository _exercisesRepository;

  bool get isFetching => state is ExerciseListLoadingState;

  ExerciseListBloc()
      : _exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(ExerciseListLoadingState()) {
    on<ExercisesFetchEvent>((_, emit) => _handleFetchEvent(emit));
    on<ModifiedOrCreatedExerciseEvent>(
        (event, emit) => _handleListModificationEvent(event, emit));
    on<DeleteExerciseEvent>(
        (event, emit) => _handleListDeletionEvent(event, emit));
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 500)));
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
        emit(ExerciseListItemModifiedState.fromState(
            state, index, ModificationType.update));
      } else {
        exercises.add(event.exercise);
        // On client sort of the new list after appending
        exercises
            .sort((a, b) => compareAsciiUpperCase(a.name ?? '', b.name ?? ''));
        emit(ExerciseListItemModifiedState.fromState(
            state,
            exercises.indexWhere((element) => element.id == event.exercise.id),
            ModificationType.creation,
            exercises: exercises));
      }
    }
  }

  Future<void> _handleListDeletionEvent(
      DeleteExerciseEvent event, Emitter emit) async {
    final index =
        state.exercises.indexWhere((element) => element.id == event.exerciseId);
    await _exercisesRepository
        .deleteExercise(event.exerciseId)
        .then((retrievedExercises) {
      final List<Exercise> exercises = List.from(state.exercises);
      exercises.removeAt(index);
      emit(ExerciseListItemModifiedState.fromState(
          state, index, ModificationType.deletion,
          exercises: exercises));
    }).catchError((err) {
      emit(ExerciseListErrorState.fromState(state, err.toString()));
    });
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    final filter = (event.filter ?? '').isEmpty ? null : event.filter;
    // Reset the whole state
    emit(ExerciseListLoadingState.fromState(state));

    await _exercisesRepository
        .getExercisesByPage(0, filter)
        .then((retrievedExercises) {
      // Do not add old exercises from state.exercises
      emit(ExerciseListLoadingState.fromState(state,
          searchFilter: filter, exercises: retrievedExercises));
    }).catchError((err) {
      emit(ExerciseListErrorState.fromState(state, err.toString()));
    });
  }

  static List<Exercise> _removeExistingExercises(
      ExerciseListState state, final List<Exercise> list) {
    return list.where((element) => !state.exercises.contains(element)).toList();
  }
}
