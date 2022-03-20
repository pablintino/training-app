import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';

part 'exercise_list_event.dart';

part 'exercise_list_state.dart';

class ExerciseListBloc extends Bloc<ExerciseListEvent, ExerciseListState> {
  final ExercisesRepository exercisesRepository;

  bool get isFetching => state is ExerciseListFetchingState;

  ExerciseListBloc()
      : exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(ExerciseListInitialState()) {
    on<ExercisesFetchEvent>((_, emit) => _handleFetchEvent(emit));
    on<DeleteExerciseEvent>(
        (event, emit) => _handleDeleteExerciseEvent(event, emit));
    on<CreateExerciseEvent>(
        (event, emit) => _handleCreateExerciseEvent(event, emit));
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit));
  }

  Future<void> _handleFetchEvent(Emitter emit) async {
    emit(ExerciseListFetchingState(state.exercises));
    try {
      final pageNumber =
          (state.exercises.length / ExercisesRepository.PAGE_SIZE).truncate();
      final retrievedExercises = await exercisesRepository.getExercisesByPage(
          pageNumber, state.searchFilter);
      List<Exercise> exercises = List.from(state.exercises)
        ..addAll(_removeExistingExercises(state, retrievedExercises));
      emit(state.exercises.length == exercises.length
          ? ExerciseListFetchExhaustedState(exercises)
          : ExerciseListFetchSuccessState(exercises));
    } catch (ex) {
      emit(ExerciseListErrorState(state.exercises, ex.toString()));
    }
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    final filter = (event.filter ?? '').isEmpty ? null : event.filter;
    emit(ExerciseListFetchingState([]));
    try {
      final retrievedExercises =
          await exercisesRepository.getExercisesByPage(0, filter);
      List<Exercise> exercises = List.from(state.exercises)
        ..addAll(_removeExistingExercises(state, retrievedExercises));
      emit(ExerciseListFetchSuccessState(exercises, searchFilter: filter));
    } catch (ex) {
      emit(ExerciseListErrorState(state.exercises, ex.toString()));
    }
  }

  Future<void> _handleCreateExerciseEvent(
      CreateExerciseEvent event, Emitter emit) async {
    await exercisesRepository.createExercise(event.exercise).then((exercise) {
      List<Exercise> exercises = List.from(state.exercises)..add(exercise);
      exercises.sort((a, b) =>
          a.name != null && b.name != null ? a.name!.compareTo(b.name!) : 0);
      emit(
          ExerciseCreationSuccessState(exercises, exercises.indexOf(exercise)));
    }).catchError((error, stackTrace) {
      emit(ExerciseCreationErrorState(state.exercises, error));
    });
  }

  Future<void> _handleDeleteExerciseEvent(
      DeleteExerciseEvent event, Emitter emit) async {
    await exercisesRepository
        .deleteExercise(event.exerciseId)
        .then((exercise) async {
      List<Exercise> exercises = List.from(state.exercises);
      exercises.removeWhere((ex) => ex.id == event.exerciseId);
      emit(ExerciseDeletionSuccessState(exercises));
    }).catchError((error, stackTrace) {
      emit(ExerciseListErrorState(state.exercises, error));
    });
  }

  static List<Exercise> _removeExistingExercises(
      ExerciseListState state, final List<Exercise> list) {
    return list.where((element) => !state.exercises.contains(element)).toList();
  }
}
