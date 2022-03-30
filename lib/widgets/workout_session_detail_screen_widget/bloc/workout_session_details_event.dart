part of 'workout_session_details_bloc.dart';

abstract class WorkoutSessionDetailsEvent extends Equatable {
  const WorkoutSessionDetailsEvent();
}

class LoadSessionEvent extends WorkoutSessionDetailsEvent {
  final int sessionId;

  LoadSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
