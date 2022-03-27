part of 'workout_list_bloc.dart';

@immutable
abstract class WorkoutListEvent extends Equatable {}

@immutable
class WorkoutFetchEvent extends WorkoutListEvent {
  final bool reload;

  WorkoutFetchEvent({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

@immutable
class SearchFilterUpdateFetchEvent extends WorkoutListEvent {
  final String? filter;

  SearchFilterUpdateFetchEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

@immutable
class DeleteWorkoutEvent extends WorkoutListEvent {
  final int workoutId;

  DeleteWorkoutEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

@immutable
class ModifiedOrCreatedWorkoutEvent extends WorkoutListEvent {
  final Workout workout;

  ModifiedOrCreatedWorkoutEvent(this.workout);

  @override
  List<Object?> get props => [workout];
}
