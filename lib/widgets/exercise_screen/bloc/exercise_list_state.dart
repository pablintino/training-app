part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListState extends Equatable {}

class ExerciseListInitialState extends ExerciseListState {
  @override
  List<Object?> get props => [];
}

class ExerciseListLoadingState extends ExerciseListState {
  @override
  List<Object?> get props => [];
}

class ExerciseListLoadingSuccessState extends ExerciseListState {
  final List<Exercise> exercises;

  ExerciseListLoadingSuccessState(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

class ExerciseListReloadSuccessState extends ExerciseListState {
  final List<Exercise> exercises;

  ExerciseListReloadSuccessState(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

class ExerciseCreationSuccessState extends ExerciseListState {
  final int newIndex;
  final List<Exercise> reloadedExercises;

  ExerciseCreationSuccessState(this.newIndex, this.reloadedExercises);

  @override
  List<Object?> get props => [newIndex, reloadedExercises];
}

class ExerciseListLoadingErrorState extends ExerciseListState {
  final String error;

  ExerciseListLoadingErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class ExerciseCreationErrorState extends ExerciseListState {
  final String error;

  ExerciseCreationErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
