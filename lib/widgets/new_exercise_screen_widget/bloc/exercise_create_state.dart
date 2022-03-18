part of 'exercise_create_bloc.dart';

abstract class ExerciseCreateState extends Equatable {
  const ExerciseCreateState();
}

class ExerciseCreateInitial extends ExerciseCreateState {
  @override
  List<Object> get props => [];
}

class SuccessExerciseCreationState extends ExerciseCreateState {
  final Exercise exercise;

  SuccessExerciseCreationState(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class ErrorExerciseCreationState extends ExerciseCreateState {
  final String error;

  ErrorExerciseCreationState(this.error);

  @override
  List<Object?> get props => [error];
}
