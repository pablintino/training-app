part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListEvent extends Equatable {}

@immutable
class ExercisesFetchEvent extends ExerciseListEvent {
  ExercisesFetchEvent();

  @override
  List<Object?> get props => [];
}

@immutable
class SearchFilterUpdateFetchEvent extends ExerciseListEvent {
  final String? filter;

  SearchFilterUpdateFetchEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

@immutable
class CreateExerciseEvent extends ExerciseListEvent {
  final Exercise exercise;

  CreateExerciseEvent(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

@immutable
class DeleteExerciseEvent extends ExerciseListEvent {
  final int exerciseId;

  DeleteExerciseEvent(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}
