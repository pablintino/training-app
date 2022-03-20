part of 'exercise_manipulation_bloc.dart';

abstract class ExerciseManipulationState extends Equatable {
  final Exercise? exercise;

  ExerciseManipulationState({this.exercise});
}

@immutable
class OnGoingExerciseManipulationState extends ExerciseManipulationState {
  final ExerciseNameField exerciseNameField;
  final ExerciseDescriptionField exerciseDescriptionField;

  OnGoingExerciseManipulationState(
      this.exerciseNameField, this.exerciseDescriptionField,
      {exercise})
      : super(exercise: exercise);

  OnGoingExerciseManipulationState copyWith(
      {ExerciseNameField? exerciseNameField,
      ExerciseDescriptionField? exerciseDescriptionField,
      Exercise? exercise}) {
    return OnGoingExerciseManipulationState(
        exerciseNameField ?? this.exerciseNameField,
        exerciseDescriptionField ?? this.exerciseDescriptionField,
        exercise: exercise ?? this.exercise);
  }

  static OnGoingExerciseManipulationState empty() {
    return OnGoingExerciseManipulationState(
        ExerciseNameField(), ExerciseDescriptionField());
  }

  @override
  List<Object?> get props =>
      [exercise, exerciseNameField, exerciseDescriptionField];
}

@immutable
class ExerciseManipulationFinishedState extends ExerciseManipulationState {
  ExerciseManipulationFinishedState._(exercise) : super(exercise: exercise);

  static ExerciseManipulationFinishedState fromState(
      ExerciseManipulationState state,
      {exercise}) {
    return ExerciseManipulationFinishedState._(exercise ?? state.exercise);
  }

  @override
  List<Object?> get props => [exercise];
}

@immutable
class ExerciseManipulationErrorState extends OnGoingExerciseManipulationState {
  final String error;

  ExerciseManipulationErrorState._(
      this.error, exercise, exerciseNameField, exerciseDescriptionField)
      : super(exerciseNameField, exerciseDescriptionField, exercise: exercise);

  static ExerciseManipulationErrorState fromState(
      OnGoingExerciseManipulationState state, String errorMessage,
      {Exercise? exercise}) {
    return ExerciseManipulationErrorState._(
        errorMessage,
        state.exerciseNameField,
        state.exerciseDescriptionField,
        exercise ?? state.exercise);
  }

  @override
  List<Object?> get props => [exercise, error];
}
