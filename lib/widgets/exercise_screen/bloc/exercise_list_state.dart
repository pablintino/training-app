part of 'exercise_list_bloc.dart';

@immutable
abstract class ExerciseListState extends Equatable {
  final List<Exercise> exercises;
  final String? searchFilter;

  ExerciseListState(this.exercises, {this.searchFilter});
}

class ExerciseListInitialState extends ExerciseListState {
  ExerciseListInitialState() : super([]);

  @override
  List<Object?> get props => [exercises, searchFilter];
}

class ExerciseListFetchingState extends ExerciseListState {
  ExerciseListFetchingState(List<Exercise> exercises) : super(exercises);

  @override
  List<Object?> get props => [exercises, searchFilter];
}

class ExerciseListFetchSuccessState extends ExerciseListState {
  ExerciseListFetchSuccessState(List<Exercise> exercises,
      {String? searchFilter})
      : super(exercises, searchFilter: searchFilter);

  @override
  List<Object?> get props => [exercises, searchFilter];
}

class ExerciseListFetchExhaustedState extends ExerciseListState {
  ExerciseListFetchExhaustedState(List<Exercise> exercises,
      {String? searchFilter})
      : super(exercises, searchFilter: searchFilter);

  @override
  List<Object?> get props => [exercises, searchFilter];
}

class ExerciseDeletionSuccessState extends ExerciseListState {
  ExerciseDeletionSuccessState(List<Exercise> exercises) : super(exercises);

  @override
  List<Object?> get props => [exercises, searchFilter];
}

class ExerciseCreationSuccessState extends ExerciseListState {
  final int newIndex;

  ExerciseCreationSuccessState(List<Exercise> exercises, int newIndex)
      : newIndex = newIndex,
        super(exercises);

  @override
  List<Object?> get props => [newIndex, exercises, searchFilter];
}

class ExerciseListErrorState extends ExerciseListState {
  final String error;

  ExerciseListErrorState(List<Exercise> exercises, String error)
      : error = error,
        super(exercises);

  @override
  List<Object?> get props => [error, exercises, searchFilter];
}

class ExerciseCreationErrorState extends ExerciseListErrorState {
  ExerciseCreationErrorState(List<Exercise> exercises, String error)
      : super(exercises, error);
}
