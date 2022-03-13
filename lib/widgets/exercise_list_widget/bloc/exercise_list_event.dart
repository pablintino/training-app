part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListEvent {}

class ExercisesFetchEvent extends ExerciseListEvent {
  ExercisesFetchEvent();
}
