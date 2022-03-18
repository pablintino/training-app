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
