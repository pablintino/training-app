part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListState extends Equatable {}

class ExerciseListInitialState extends ExerciseListState {
  @override
  List<Object?> get props => [];
}

class ExerciseListLoadingState extends ExerciseListState {
  final String message;

  ExerciseListLoadingState(this.message);

  @override
  List<Object?> get props => [message];
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

class ExerciseListLoadingErrorState extends ExerciseListState {
  final String error;

  ExerciseListLoadingErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
