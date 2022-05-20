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

class SaveWorkoutEditionEvent extends WorkoutManipulatorEvent {
  const SaveWorkoutEditionEvent();

  @override
  List<Object?> get props => [];
}

class NameInputUpdateEvent extends WorkoutManipulatorEvent {
  final String? nameValue;

  NameInputUpdateEvent(this.nameValue);

  @override
  List<Object?> get props => [nameValue];
}

class DescriptionInputUpdateEvent extends WorkoutManipulatorEvent {
  final String? descriptionValue;

  DescriptionInputUpdateEvent(this.descriptionValue);

  @override
  List<Object?> get props => [descriptionValue];
}

class SetSessionDraggingEvent extends WorkoutManipulatorEvent {
  final bool isDragging;

  SetSessionDraggingEvent(this.isDragging);

  @override
  List<Object?> get props => [isDragging];
}
