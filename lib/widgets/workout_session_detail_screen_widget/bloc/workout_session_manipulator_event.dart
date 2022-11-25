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
  final int phaseId;
  final int targetSequence;

  MoveWorkoutPhaseEditionEvent(this.phaseId, this.targetSequence);

  @override
  List<Object?> get props => [phaseId, targetSequence];
}

class MoveWorkoutItemEditionEvent extends WorkoutSessionManipulatorEvent {
  final int workoutItemId;
  final int parentPhaseId;
  final int targetSequence;

  MoveWorkoutItemEditionEvent(
      this.workoutItemId, this.parentPhaseId, this.targetSequence);

  @override
  List<Object?> get props => [workoutItemId, targetSequence, parentPhaseId];
}

class DeleteWorkoutPhaseEditionEvent extends WorkoutSessionManipulatorEvent {
  final int workputPhaseId;

  DeleteWorkoutPhaseEditionEvent(this.workputPhaseId);

  @override
  List<Object?> get props => [workputPhaseId];
}
