part of 'workout_session_manipulator_bloc.dart';

abstract class WorkoutSessionManipulatorEvent extends Equatable {
  const WorkoutSessionManipulatorEvent();
}

class LoadSessionEvent extends WorkoutSessionManipulatorEvent {
  final int sessionId;
  final bool initEditMode;

  LoadSessionEvent(this.sessionId, this.initEditMode);

  @override
  List<Object?> get props => [sessionId, initEditMode];
}

class StartWorkoutSessionEditionEvent extends WorkoutSessionManipulatorEvent {
  const StartWorkoutSessionEditionEvent();

  @override
  List<Object?> get props => [];
}

class SaveSessionWorkoutEditionEvent extends WorkoutSessionManipulatorEvent {
  const SaveSessionWorkoutEditionEvent();

  @override
  List<Object?> get props => [];
}

class MoveWorkoutPhaseEditionEvent extends WorkoutSessionManipulatorEvent {
  final WorkoutPhase phase;
  final int targetSequence;

  MoveWorkoutPhaseEditionEvent(this.phase, this.targetSequence);

  @override
  List<Object?> get props => [phase, targetSequence];
}
