part of 'workout_details_bloc.dart';

abstract class WorkoutDetailsState extends Equatable {
  const WorkoutDetailsState();
}

class WorkoutDetailsInitial extends WorkoutDetailsState {
  @override
  List<Object> get props => [];
}

class WorkoutLoadedState extends WorkoutDetailsState {
  final Workout workout;
  final bool isDragging;

  WorkoutLoadedState({required this.workout, required this.isDragging});

  static WorkoutLoadedState fromState(
    WorkoutLoadedState state, {
    workout,
    isDragging,
  }) {
    return WorkoutLoadedState(
        workout: workout ?? state.workout,
        isDragging: isDragging ?? state.isDragging);
  }

  @override
  List<Object?> get props => [workout, isDragging];
}
