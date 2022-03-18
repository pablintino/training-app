import 'dart:async';

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
    on<SearchFilterUpdateFetchEvent>(
        (event, emit) => _handleFilterChangeEvent(event, emit));
  }

  Future<void> _handleFetchEvent(Emitter emit) async {
    emit(ExerciseListLoadingState('Loading exercises'));
    final response = await exercisesRepository.getExercises(page, filter);
    emit(ExerciseListLoadingSuccessState(response));
    page++;
  }

  Future<void> _handleFilterChangeEvent(
      SearchFilterUpdateFetchEvent event, Emitter emit) async {
    emit(ExerciseListLoadingState('Loading exercises'));
    page = 0;
    filter = (event.filter ?? '').isEmpty ? null : event.filter;
    final response = await exercisesRepository.getExercises(page, filter);
    emit(ExerciseListReloadSuccessState(response));
    page++;
  }
}
