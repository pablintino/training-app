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

  WorkoutLoadedState(this.workout);

  @override
  List<Object?> get props => [workout];
}
