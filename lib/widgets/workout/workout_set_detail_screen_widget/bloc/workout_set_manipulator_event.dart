part of 'workout_set_manipulator_bloc.dart';

abstract class WorkoutSetManipulatorEvent extends Equatable {
  const WorkoutSetManipulatorEvent();
}

class LoadSetEvent extends WorkoutSetManipulatorEvent {
  final WorkoutSet workoutSet;

  LoadSetEvent(this.workoutSet);

  @override
  List<Object?> get props => [workoutSet];
}

class WorkoutSetRepetitionsChanged extends WorkoutSetManipulatorEvent {
  final int? repetitions;

  WorkoutSetRepetitionsChanged(this.repetitions);

  @override
  List<Object?> get props => [repetitions];
}

class WorkoutSetExecutionsChanged extends WorkoutSetManipulatorEvent {
  final int? executions;

  WorkoutSetExecutionsChanged(this.executions);

  @override
  List<Object?> get props => [executions];
}

class WorkoutSetDistanceChanged extends WorkoutSetManipulatorEvent {
  final int? distance;

  WorkoutSetDistanceChanged(this.distance);

  @override
  List<Object?> get props => [distance];
}

class WorkoutSetWeightChanged extends WorkoutSetManipulatorEvent {
  final int? weight;

  WorkoutSetWeightChanged(this.weight);

  @override
  List<Object?> get props => [weight];
}

class WorkoutSetExerciseChanged extends WorkoutSetManipulatorEvent {
  final Exercise? exercise;

  WorkoutSetExerciseChanged(this.exercise);

  @override
  List<Object?> get props => [exercise];
}
