part of 'exercise_create_bloc.dart';

abstract class ExerciseCreationEvent extends Equatable {
  const ExerciseCreationEvent();
}

class NewExerciseCreationEvent extends ExerciseCreationEvent {
  final Exercise exercise;

  NewExerciseCreationEvent(this.exercise);

  @override
  List<Object?> get props => [exercise];
}