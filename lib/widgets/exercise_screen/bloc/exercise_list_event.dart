part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListEvent extends Equatable {}

@immutable
class ExercisesFetchEvent extends ExerciseListEvent {
  final bool reload;

  ExercisesFetchEvent({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

@immutable
class SearchFilterUpdateFetchEvent extends ExerciseListEvent {
  final String? filter;

  SearchFilterUpdateFetchEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

@immutable
class DeleteExerciseEvent extends ExerciseListEvent {
  final int exerciseId;

  DeleteExerciseEvent(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

@immutable
class ModifiedOrCreatedExerciseEvent extends ExerciseListEvent {
  final Exercise exercise;

  ModifiedOrCreatedExerciseEvent(this.exercise);

  @override
  List<Object?> get props => [exercise];
}
