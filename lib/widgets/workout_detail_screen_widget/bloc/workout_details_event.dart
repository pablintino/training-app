part of 'workout_details_bloc.dart';

abstract class WorkoutDetailsEvent extends Equatable {
  const WorkoutDetailsEvent();
}

class LoadWorkoutEvent extends WorkoutDetailsEvent {
  final int workoutId;

  LoadWorkoutEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}
