import 'dart:async';
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
  int page = 0;
  bool isFetching = false;
  String? filter;

  ExerciseListBloc()
      : exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(ExerciseListInitialState()) {
    on<ExercisesFetchEvent>((_, emit) => _handleFetchEvent(emit));
    on<CreateExerciseEvent>(
        (event, emit) => _handleCreateExerciseEvent(event, emit));
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit));
  }

  Future<void> _handleFetchEvent(Emitter emit) async {
    emit(ExerciseListLoadingState());
    final response = await exercisesRepository.getExercises(page, filter);
    emit(ExerciseListLoadingSuccessState(response));
    page++;
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    emit(ExerciseListLoadingState());
    page = 0;
    filter = (event.filter ?? '').isEmpty ? null : event.filter;

    await exercisesRepository.getExercises(page, filter).then((exercises) {
      emit(ExerciseListReloadSuccessState(exercises));
      page++;
    }).catchError((error, stackTrace) {
      emit(ExerciseListLoadingErrorState(error));
    });
  }

  Future<void> _handleCreateExerciseEvent(
      CreateExerciseEvent event, Emitter emit) async {
    await exercisesRepository
        .createExercise(event.exercise)
        .then((exercise) async => await exercisesRepository
                .walkUntilExercise(exercise.id)
                .then((tuple) {
              page = tuple.item2;

              emit(ExerciseCreationSuccessState(
                  tuple.item1
                      .indexWhere((element) => exercise.id == element.id),
                  tuple.item1));
            }).catchError((error, stackTrace) {
              emit(ExerciseListLoadingErrorState(error));
            }))
        .catchError((error, stackTrace) {
      emit(ExerciseCreationErrorState(error));
    });
  }
}
