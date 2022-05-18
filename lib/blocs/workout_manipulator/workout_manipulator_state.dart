part of 'workout_manipulator_bloc.dart';

abstract class WorkoutManipulatorState extends Equatable {
  const WorkoutManipulatorState();
}

class WorkoutManipulatorInitialState extends WorkoutManipulatorState {
  @override
  List<Object> get props => [];
}

class WorkoutManipulatorLoadedState extends WorkoutManipulatorState {
  final Workout workout;

  WorkoutManipulatorLoadedState({required this.workout});

  static WorkoutManipulatorLoadedState fromState(
    WorkoutManipulatorLoadedState state, {
    workout,
  }) {
    return WorkoutManipulatorLoadedState(
      workout: workout ?? state.workout,
    );
  }

  @override
  List<Object?> get props => [workout];
}

class WorkoutManipulatorEditingState extends WorkoutManipulatorLoadedState {
  WorkoutManipulatorEditingState({required Workout workout})
      : super(workout: workout);

  static WorkoutManipulatorEditingState fromLoadedState(
    WorkoutManipulatorLoadedState state, {
    workout,
  }) {
    return WorkoutManipulatorEditingState(
      workout: workout ?? state.workout,
    );
  }

  @override
  List<Object?> get props => [workout];
}
