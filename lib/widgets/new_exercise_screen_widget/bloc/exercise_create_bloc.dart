import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';

part 'exercise_create_event.dart';

part 'exercise_create_state.dart';

class ExerciseCreateBloc
    extends Bloc<ExerciseCreationEvent, ExerciseCreateState> {
  final ExercisesRepository _exercisesRepository =
      GetIt.instance<ExercisesRepository>();

  ExerciseCreateBloc() : super(ExerciseCreateInitial()) {
    on<NewExerciseCreationEvent>(
        (event, emit) => createExercise(event.exercise, emit));
  }

  Future<void> createExercise(
      Exercise exercise, Emitter<ExerciseCreateState> emit) async {
    await _exercisesRepository
        .createExercise(exercise)
        .then((value) => emit(SuccessExerciseCreationState(value)))
        .catchError((err) => emit(ErrorExerciseCreationState(err)));
  }
}
