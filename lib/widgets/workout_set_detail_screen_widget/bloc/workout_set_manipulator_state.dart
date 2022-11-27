part of 'workout_set_manipulator_bloc.dart';

abstract class WorkoutSetManipulatorState extends Equatable {
  const WorkoutSetManipulatorState();
}

class WorkoutSetManipulatorInitial extends WorkoutSetManipulatorState {
  @override
  List<Object> get props => [];
}

class WorkoutSetManipulatorEditingState extends WorkoutSetManipulatorState {
  final WorkoutSet workoutSet;
  final IntegerField workoutSetReps;
  final IntegerField workoutSetWeight;
  final IntegerField workoutSetExecutions;
  final IntegerField workoutSetDistance;
  final Exercise? exercise;
  final List<Exercise> availableExercises;

  WorkoutSetManipulatorEditingState({
    required this.workoutSet,
    required this.workoutSetReps,
    required this.workoutSetWeight,
    required this.workoutSetExecutions,
    required this.workoutSetDistance,
    required this.exercise,
    required this.availableExercises,
  });

  WorkoutSetManipulatorEditingState copyWith(
      {WorkoutSet? workoutSet,
      IntegerField? workoutSetReps,
      IntegerField? workoutSetWeight,
      IntegerField? workoutSetExecutions,
      IntegerField? workoutSetDistance,
      Exercise? exercise,
      List<Exercise>? availableExercises}) {
    return WorkoutSetManipulatorEditingState(
        workoutSet: workoutSet ?? this.workoutSet,
        workoutSetReps: workoutSetReps ?? this.workoutSetReps,
        workoutSetWeight: workoutSetWeight ?? this.workoutSetWeight,
        workoutSetExecutions: workoutSetExecutions ?? this.workoutSetExecutions,
        workoutSetDistance: workoutSetDistance ?? this.workoutSetDistance,
        exercise: exercise ?? this.exercise,
        availableExercises: availableExercises ?? this.availableExercises);
  }

  @override
  List<Object?> get props => [
        workoutSet,
        workoutSetReps,
        workoutSetWeight,
        workoutSetExecutions,
        workoutSetDistance,
        exercise,
        availableExercises
      ];
}

class WorkoutSetManipulatorErrorState
    extends WorkoutSetManipulatorEditingState {
  final String error;

  WorkoutSetManipulatorErrorState._(
    this.error, {
    required WorkoutSet workoutSet,
    required IntegerField workoutSetReps,
    required IntegerField workoutSetWeight,
    required IntegerField workoutSetExecutions,
    required IntegerField workoutSetDistance,
    required Exercise? exercise,
    required List<Exercise> availableExercises,
  }) : super(
            workoutSet: workoutSet,
            workoutSetReps: workoutSetReps,
            workoutSetWeight: workoutSetWeight,
            workoutSetExecutions: workoutSetExecutions,
            workoutSetDistance: workoutSetDistance,
            exercise: exercise,
            availableExercises: availableExercises);

  static WorkoutSetManipulatorErrorState fromState(
      WorkoutSetManipulatorEditingState state, String errorMessage,
      {WorkoutSet? workoutSet,
      IntegerField? workoutSetReps,
      IntegerField? workoutSetWeight,
      IntegerField? workoutSetExecutions,
      IntegerField? workoutSetDistance,
      Exercise? exercise,
      List<Exercise>? availableExercises}) {
    return WorkoutSetManipulatorErrorState._(errorMessage,
        workoutSet: workoutSet ?? state.workoutSet,
        workoutSetReps: workoutSetReps ?? state.workoutSetReps,
        workoutSetWeight: workoutSetWeight ?? state.workoutSetWeight,
        workoutSetExecutions:
            workoutSetExecutions ?? state.workoutSetExecutions,
        workoutSetDistance: workoutSetDistance ?? state.workoutSetDistance,
        exercise: exercise ?? state.exercise,
        availableExercises: availableExercises ?? state.availableExercises);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}
