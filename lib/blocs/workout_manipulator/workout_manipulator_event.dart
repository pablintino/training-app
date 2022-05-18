part of 'workout_manipulator_bloc.dart';

abstract class WorkoutManipulatorEvent extends Equatable {
  const WorkoutManipulatorEvent();
}

class LoadWorkoutEvent extends WorkoutManipulatorEvent {
  final int workoutId;

  LoadWorkoutEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class StartWorkoutEditionEvent extends WorkoutManipulatorEvent {
  const StartWorkoutEditionEvent();

  @override
  List<Object?> get props => [];
}
