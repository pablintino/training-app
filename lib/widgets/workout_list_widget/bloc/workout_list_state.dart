part of 'workout_list_bloc.dart';

abstract class WorkoutListState extends Equatable {
  final List<Workout> workouts;
  final String? searchFilter;

  const WorkoutListState(
      {this.workouts = const <Workout>[], this.searchFilter});

  @override
  List<Object?> get props => [workouts, searchFilter];
}

@immutable
class StartListLoadingState extends WorkoutListState {
  const StartListLoadingState({List<Workout>? workouts, String? searchFilter})
      : super(
            workouts: workouts ?? const <Workout>[],
            searchFilter: searchFilter);

  static StartListLoadingState fromState(
    WorkoutListState state, {
    workouts,
    searchFilter,
  }) {
    return StartListLoadingState(
        workouts: workouts ?? state.workouts,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

@immutable
class WorkoutListLoadingState extends WorkoutListState {
  const WorkoutListLoadingState({List<Workout>? workouts, String? searchFilter})
      : super(
            workouts: workouts ?? const <Workout>[],
            searchFilter: searchFilter);

  static WorkoutListLoadingState fromState(
    WorkoutListState state, {
    workouts,
    searchFilter,
  }) {
    return WorkoutListLoadingState(
        workouts: workouts ?? state.workouts,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

enum ModificationType { deletion, creation, update }

@immutable
class WorkoutListItemModifiedState extends WorkoutListState {
  final int modifiedIndex;
  final ModificationType type;

  const WorkoutListItemModifiedState(modifiedIndex, type,
      {workouts, searchFilter})
      : modifiedIndex = modifiedIndex,
        type = type,
        super(
            workouts: workouts ?? const <Workout>[],
            searchFilter: searchFilter);

  WorkoutListItemModifiedState.fromState(
    WorkoutListState state,
    modifiedIndex,
    type, {
    workouts,
    searchFilter,
  })  : modifiedIndex = modifiedIndex,
        type = type,
        super(
            workouts: workouts ?? state.workouts,
            searchFilter: searchFilter ?? state.searchFilter);

  @override
  List<Object?> get props => [workouts, searchFilter, modifiedIndex, type];
}

@immutable
class WorkoutListErrorState extends WorkoutListState {
  final String errorMessage;

  const WorkoutListErrorState._(errorMessage, {workouts, searchFilter})
      : errorMessage = errorMessage,
        super(workouts: workouts ?? const <Workout>[]);

  static fromState(
    WorkoutListState state,
    errorMessage, {
    exercises,
  }) {
    return WorkoutListErrorState._(errorMessage,
        workouts: exercises ?? state.workouts,
        searchFilter: state.searchFilter);
  }

  @override
  List<Object?> get props => [workouts, searchFilter, errorMessage];
}
