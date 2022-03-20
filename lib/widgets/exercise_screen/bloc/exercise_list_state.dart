part of 'exercise_list_bloc.dart';

class ExerciseListState extends Equatable {
  final List<Exercise> exercises;
  final String? searchFilter;

  const ExerciseListState(
      {this.exercises = const <Exercise>[], this.searchFilter});

  @override
  List<Object?> get props => [exercises, searchFilter];
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
    List<Exercise>? exercises,
    String? searchFilter,
  }) {
    return ExerciseListLoadingState(
        exercises: exercises ?? state.exercises,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

@immutable
class ExerciseListItemModifiedState extends ExerciseListState {
  final int modifiedIndex;

  const ExerciseListItemModifiedState(int modifiedIndex,
      {List<Exercise>? exercises, String? searchFilter})
      : modifiedIndex = modifiedIndex,
        super(
            exercises: exercises ?? const <Exercise>[],
            searchFilter: searchFilter);

  static ExerciseListItemModifiedState fromState(
    ExerciseListState state,
    int modifiedIndex, {
    List<Exercise>? exercises,
    String? searchFilter,
  }) {
    return ExerciseListItemModifiedState(modifiedIndex,
        exercises: exercises ?? state.exercises,
        searchFilter: searchFilter ?? state.searchFilter);
  }
}

@immutable
class ExerciseListErrorState extends ExerciseListState {
  final String errorMessage;

  const ExerciseListErrorState._(String errorMessage,
      {List<Exercise>? exercises, String? searchFilter})
      : errorMessage = errorMessage,
        super(exercises: exercises ?? const <Exercise>[]);

  static fromState(
    ExerciseListState state,
    String errorMessage, {
    List<Exercise>? exercises,
  }) {
    return ExerciseListErrorState._(errorMessage,
        exercises: exercises ?? state.exercises,
        searchFilter: state.searchFilter);
  }
}
