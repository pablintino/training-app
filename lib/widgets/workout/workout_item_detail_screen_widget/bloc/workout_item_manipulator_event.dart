part of 'workout_item_manipulator_bloc.dart';

abstract class WorkoutItemManipulatorEvent extends Equatable {
  const WorkoutItemManipulatorEvent();
}

class LoadItemEvent extends WorkoutItemManipulatorEvent {
  final WorkoutItem workoutItem;
  final WorkoutPhase parentWorkoutPhase;

  LoadItemEvent(this.workoutItem, this.parentWorkoutPhase);

  @override
  List<Object?> get props => [workoutItem];
}

class WorkoutItemWorkTimeChanged extends WorkoutItemManipulatorEvent {
  final int? workTimeSecs;

  WorkoutItemWorkTimeChanged(this.workTimeSecs);

  @override
  List<Object?> get props => [workTimeSecs];
}

class WorkoutItemRestTimeChanged extends WorkoutItemManipulatorEvent {
  final int? restTimeSecs;

  WorkoutItemRestTimeChanged(this.restTimeSecs);

  @override
  List<Object?> get props => [restTimeSecs];
}

class WorkoutItemTimeCapChanged extends WorkoutItemManipulatorEvent {
  final int? timeCapSecs;

  WorkoutItemTimeCapChanged(this.timeCapSecs);

  @override
  List<Object?> get props => [timeCapSecs];
}

class WorkoutItemRoundsChanged extends WorkoutItemManipulatorEvent {
  final int? rounds;

  WorkoutItemRoundsChanged(this.rounds);

  @override
  List<Object?> get props => [rounds];
}

class WorkoutItemNameChanged extends WorkoutItemManipulatorEvent {
  final String? name;

  WorkoutItemNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class WorkoutItemModalityChanged extends WorkoutItemManipulatorEvent {
  final String? modality;

  WorkoutItemModalityChanged(this.modality);

  @override
  List<Object?> get props => [modality];
}

class MoveWorkoutSetEditionEvent extends WorkoutItemManipulatorEvent {
  final WorkoutSet set;
  final int targetSequence;

  MoveWorkoutSetEditionEvent(this.set, this.targetSequence);

  @override
  List<Object?> get props => [set, targetSequence];
}
