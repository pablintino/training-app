part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListState {}

class ExerciseListInitialState extends ExerciseListState {}

class ExerciseListLoadingState extends ExerciseListState {
  final String message;

  ExerciseListLoadingState(this.message);
}

class ExerciseListLoadingSuccessState extends ExerciseListState {
  final List<Exercise> exercises;

  ExerciseListLoadingSuccessState(this.exercises);
}

class ExerciseListLoadingErrorState extends ExerciseListState {
  final String error;

  ExerciseListLoadingErrorState(this.error);
}
