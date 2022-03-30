part of 'workout_session_details_bloc.dart';

abstract class WorkoutSessionDetailsState extends Equatable {
  const WorkoutSessionDetailsState();
}

class WorkoutSessionDetailsInitial extends WorkoutSessionDetailsState {
  @override
  List<Object> get props => [];
}

class SessionLoadedState extends WorkoutSessionDetailsState {
  final WorkoutSession workoutSession;

  SessionLoadedState(this.workoutSession);

  @override
  List<Object?> get props => [workoutSession];
}
