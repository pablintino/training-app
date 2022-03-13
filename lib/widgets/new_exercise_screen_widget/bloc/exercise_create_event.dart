part of 'exercise_create_bloc.dart';

abstract class ExerciseCreateEvent extends Equatable {
  const ExerciseCreateEvent();
}

class NewExerciseCreateEvent extends Equatable {
  final Exercise exercise;

  NewExerciseCreateEvent(this.exercise);

  @override
  List<Object?> get props => [exercise];
}
