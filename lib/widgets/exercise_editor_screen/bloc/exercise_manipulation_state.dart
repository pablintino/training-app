part of 'exercise_manipulation_bloc.dart';

abstract class ExerciseManipulationState extends Equatable {
  final Exercise? initialExercise;

  ExerciseManipulationState({this.initialExercise});
}

@immutable
class OnGoingExerciseManipulationState extends ExerciseManipulationState {
  final StringField exerciseName;
  final StringField exerciseDescription;

  OnGoingExerciseManipulationState(this.exerciseName, this.exerciseDescription,
      {initialExercise})
      : super(initialExercise: initialExercise);

  OnGoingExerciseManipulationState copyWith(
      {StringField? exerciseName,
      StringField? exerciseDescription,
      Exercise? exercise}) {
    return OnGoingExerciseManipulationState(exerciseName ?? this.exerciseName,
        exerciseDescription ?? this.exerciseDescription,
        initialExercise: exercise ?? this.initialExercise);
  }

  static OnGoingExerciseManipulationState empty() {
    return OnGoingExerciseManipulationState(StringField(), StringField());
  }

  static OnGoingExerciseManipulationState pure(
      String? name, String? description,
      {initialExercise}) {
    return OnGoingExerciseManipulationState(
        StringField(value: name), StringField(value: description),
        initialExercise: initialExercise);
  }

  @override
  List<Object?> get props =>
      [initialExercise, exerciseName, exerciseDescription];
}

@immutable
class ExerciseManipulationFinishedState extends ExerciseManipulationState {
  ExerciseManipulationFinishedState._(exercise)
      : super(initialExercise: exercise);

  static ExerciseManipulationFinishedState fromState(
      ExerciseManipulationState state,
      {exercise}) {
    return ExerciseManipulationFinishedState._(
        exercise ?? state.initialExercise);
  }

  @override
  List<Object?> get props => [initialExercise];
}

@immutable
class ExerciseManipulationErrorState extends OnGoingExerciseManipulationState {
  final String error;

  ExerciseManipulationErrorState._(
      this.error, StringField exerciseName, StringField exerciseDescription,
      {Exercise? initialExercise})
      : super(exerciseName, exerciseDescription,
            initialExercise: initialExercise);

  static ExerciseManipulationErrorState fromState(
      OnGoingExerciseManipulationState state, String errorMessage,
      {Exercise? initialExercise}) {
    return ExerciseManipulationErrorState._(
        errorMessage, state.exerciseName, state.exerciseDescription,
        initialExercise: initialExercise ?? state.initialExercise);
  }

  @override
  List<Object?> get props =>
      [initialExercise, error, exerciseName, exerciseDescription];
}
