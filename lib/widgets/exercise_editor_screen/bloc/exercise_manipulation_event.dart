part of 'exercise_manipulation_bloc.dart';

abstract class ExerciseManipulationEvent extends Equatable {
  const ExerciseManipulationEvent();
}

@immutable
class NameInputUpdateEvent extends ExerciseManipulationEvent {
  final String? nameValue;

  NameInputUpdateEvent(this.nameValue);

  @override
  List<Object?> get props => [nameValue];
}

@immutable
class DescriptionInputUpdateEvent extends ExerciseManipulationEvent {
  final String? descriptionValue;

  DescriptionInputUpdateEvent(this.descriptionValue);

  @override
  List<Object?> get props => [descriptionValue];
}

@immutable
class SubmitExerciseEvent extends ExerciseManipulationEvent {
  SubmitExerciseEvent();

  @override
  List<Object?> get props => [];
}
