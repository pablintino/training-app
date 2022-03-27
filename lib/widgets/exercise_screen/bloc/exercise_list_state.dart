part of 'exercise_list_bloc.dart';

abstract class ExerciseListState extends Equatable {
  final List<Exercise> exercises;
  final String? searchFilter;

  const ExerciseListState(
      {this.exercises = const <Exercise>[], this.searchFilter});

  @override
  List<Object?> get props => [exercises, searchFilter];
}

@immutable
class StartedListLoadingState extends ExerciseListState {
  const StartedListLoadingState(
      {List<Exercise>? exercises, String? searchFilter})
      : super(
            exercises: exercises ?? const <Exercise>[],
            searchFilter: searchFilter);

  static StartedListLoadingState fromState(
    ExerciseListState state, {
    exercises,
    searchFilter,
  }) {
    return StartedListLoadingState(
        exercises: exercises ?? state.exercises,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

@immutable
class ExerciseListLoadingState extends ExerciseListState {
  const ExerciseListLoadingState(
      {List<Exercise>? exercises, String? searchFilter})
      : super(
            exercises: exercises ?? const <Exercise>[],
            searchFilter: searchFilter);

  static ExerciseListLoadingState fromState(
    ExerciseListState state, {
    exercises,
    searchFilter,
  }) {
    return ExerciseListLoadingState(
        exercises: exercises ?? state.exercises,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

enum ModificationType { deletion, creation, update }

@immutable
class ExerciseListItemModifiedState extends ExerciseListState {
  final int modifiedIndex;
  final ModificationType type;

  const ExerciseListItemModifiedState(modifiedIndex, type,
      {exercises, searchFilter})
      : modifiedIndex = modifiedIndex,
        type = type,
        super(
            exercises: exercises ?? const <Exercise>[],
            searchFilter: searchFilter);

  ExerciseListItemModifiedState.fromState(
    ExerciseListState state,
    modifiedIndex,
    type, {
    exercises,
    searchFilter,
  })  : modifiedIndex = modifiedIndex,
        type = type,
        super(
            exercises: exercises ?? state.exercises,
            searchFilter: searchFilter ?? state.searchFilter);

  @override
  List<Object?> get props => [exercises, searchFilter, modifiedIndex, type];
}

@immutable
class ExerciseListErrorState extends ExerciseListState {
  final String errorMessage;

  const ExerciseListErrorState._(errorMessage, {exercises, searchFilter})
      : errorMessage = errorMessage,
        super(exercises: exercises ?? const <Exercise>[]);

  static fromState(
    ExerciseListState state,
    errorMessage, {
    exercises,
  }) {
    return ExerciseListErrorState._(errorMessage,
        exercises: exercises ?? state.exercises,
        searchFilter: state.searchFilter);
  }

  @override
  List<Object?> get props => [exercises, searchFilter, errorMessage];
}
