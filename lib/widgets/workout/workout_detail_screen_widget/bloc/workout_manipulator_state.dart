part of 'workout_manipulator_bloc.dart';

abstract class WorkoutManipulatorState extends Equatable {
  const WorkoutManipulatorState();
}

class WorkoutManipulatorInitialState extends WorkoutManipulatorState {
  @override
  List<Object> get props => [];
}

class WorkoutManipulatorLoadedState extends WorkoutManipulatorState {
  final Workout workout;

  WorkoutManipulatorLoadedState({required this.workout});

  static WorkoutManipulatorLoadedState fromState(
    WorkoutManipulatorLoadedState state, {
    workout,
  }) {
    return WorkoutManipulatorLoadedState(
      workout: workout ?? state.workout,
    );
  }

  @override
  List<Object?> get props => [workout];
}

class WorkoutManipulatorEditingState extends WorkoutManipulatorLoadedState {
  final bool isDragging;
  final StringField workoutName;
  final StringField workoutDescription;
  final Map<int, WorkoutSession> movedSessions;

  WorkoutManipulatorEditingState(
      {required Workout workout,
      required this.isDragging,
      required this.workoutName,
      required this.workoutDescription,
      required this.movedSessions})
      : super(workout: workout);

  WorkoutManipulatorEditingState copyWith(
      {StringField? workoutName,
      StringField? workoutDescription,
      bool? isDraggingSession,
      Workout? workout,
      Map<int, WorkoutSession>? movedSessions}) {
    return WorkoutManipulatorEditingState(
        workoutName: workoutName ?? this.workoutName,
        workoutDescription: workoutDescription ?? this.workoutDescription,
        isDragging: isDraggingSession ?? this.isDragging,
        workout: workout ?? this.workout,
        movedSessions: movedSessions ?? this.movedSessions);
  }

  static WorkoutManipulatorEditingState fromLoadedState(
      WorkoutManipulatorLoadedState state,
      {Workout? workout,
      bool? isDragging}) {
    return WorkoutManipulatorEditingState(
        workout: workout ?? state.workout,
        workoutName: StringField(value: (workout ?? state.workout).name),
        workoutDescription:
            StringField(value: (workout ?? state.workout).description),
        isDragging: isDragging ?? false,
        movedSessions: Map());
  }

  @override
  List<Object?> get props => [
        isDragging,
        workoutName,
        workoutDescription,
        movedSessions,
        ...super.props
      ];
}

class WorkoutManipulatorErrorState extends WorkoutManipulatorEditingState {
  final String error;

  WorkoutManipulatorErrorState._(this.error,
      {required Workout workout,
      required bool isDragging,
      required StringField workoutName,
      required StringField workoutDescription,
      required Map<int, WorkoutSession> movedSessions})
      : super(
            workoutName: workoutName,
            workoutDescription: workoutDescription,
            isDragging: isDragging,
            workout: workout,
            movedSessions: movedSessions);

  static WorkoutManipulatorErrorState fromState(
      WorkoutManipulatorEditingState state, String errorMessage,
      {Workout? workout}) {
    return WorkoutManipulatorErrorState._(errorMessage,
        workoutName: state.workoutName,
        workoutDescription: state.workoutDescription,
        workout: workout ?? state.workout,
        isDragging: state.isDragging,
        movedSessions: state.movedSessions);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}