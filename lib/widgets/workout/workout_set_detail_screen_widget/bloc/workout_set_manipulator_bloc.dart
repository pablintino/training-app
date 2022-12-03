import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';

part 'workout_set_manipulator_event.dart';

part 'workout_set_manipulator_state.dart';

class WorkoutSetManipulatorBloc
    extends Bloc<WorkoutSetManipulatorEvent, WorkoutSetManipulatorState> {
  final ExercisesRepository _exercisesRepository;
  final WorkoutGlobalEditingBloc workoutGlobalEditingBloc;

  WorkoutSetManipulatorBloc(this.workoutGlobalEditingBloc)
      : _exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(WorkoutSetManipulatorInitial()) {
    on<LoadSetEvent>((event, emit) => _handleLoadSetEvent(emit, event));
    on<WorkoutSetExecutionsChanged>(
        (event, emit) => _handleWorkoutSetExecutionsChanged(emit, event));
    on<WorkoutSetRepetitionsChanged>(
        (event, emit) => _handleWorkoutSetRepetitionsChanged(emit, event));
    on<WorkoutSetWeightChanged>(
        (event, emit) => _handleWorkoutSetWeightChanged(emit, event));
    on<WorkoutSetDistanceChanged>(
        (event, emit) => _handleWorkoutSetDistanceChanged(emit, event));
    on<WorkoutSetExerciseChanged>(
        (event, emit) => _handleWorkoutSetExerciseChanged(emit, event));
  }

  void _handleWorkoutSetExerciseChanged(
      Emitter emit, WorkoutSetExerciseChanged event) {
    if (state is WorkoutSetManipulatorEditingState) {
      final currentState = state as WorkoutSetManipulatorEditingState;
      emit(currentState.copyWith(exercise: event.exercise));
    }
  }

  void _handleWorkoutSetExecutionsChanged(
      Emitter emit, WorkoutSetExecutionsChanged event) {
    if (state is WorkoutSetManipulatorEditingState) {
      final currentState = state as WorkoutSetManipulatorEditingState;
      emit(currentState.copyWith(
          workoutSetExecutions: IntegerField.createValidFrom(
              currentState.workoutSetExecutions, event.executions)));
    }
  }

  void _handleWorkoutSetRepetitionsChanged(
      Emitter emit, WorkoutSetRepetitionsChanged event) {
    if (state is WorkoutSetManipulatorEditingState) {
      final currentState = state as WorkoutSetManipulatorEditingState;
      emit(currentState.copyWith(
          workoutSetReps: IntegerField.createValidFrom(
              currentState.workoutSetReps, event.repetitions)));
    }
  }

  void _handleWorkoutSetWeightChanged(
      Emitter emit, WorkoutSetWeightChanged event) {
    if (state is WorkoutSetManipulatorEditingState) {
      final currentState = state as WorkoutSetManipulatorEditingState;
      emit(currentState.copyWith(
          workoutSetWeight: IntegerField.createValidFrom(
              currentState.workoutSetWeight, event.weight)));
    }
  }

  void _handleWorkoutSetDistanceChanged(
      Emitter emit, WorkoutSetDistanceChanged event) {
    if (state is WorkoutSetManipulatorEditingState) {
      final currentState = state as WorkoutSetManipulatorEditingState;
      emit(currentState.copyWith(
          workoutSetDistance: IntegerField.createValidFrom(
              currentState.workoutSetDistance, event.distance)));
    }
  }

  Future<void> _handleLoadSetEvent(Emitter emit, LoadSetEvent event) async {
    emit(WorkoutSetManipulatorEditingState(
        workoutSet: event.workoutSet,
        workoutSetExecutions:
            IntegerField(value: event.workoutSet.setExecutions),
        workoutSetReps: IntegerField(value: event.workoutSet.reps),
        workoutSetWeight: IntegerField(value: event.workoutSet.weight),
        workoutSetDistance: IntegerField(value: event.workoutSet.distance),
        exercise: event.workoutSet.exercise,
        // TODO Handle DB load error
        availableExercises: await _exercisesRepository.getExercises()));
  }
}
