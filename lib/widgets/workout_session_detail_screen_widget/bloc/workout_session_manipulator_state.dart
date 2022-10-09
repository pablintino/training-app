part of 'workout_session_manipulator_bloc.dart';

abstract class WorkoutSessionManipulatorState extends Equatable {
  const WorkoutSessionManipulatorState();
}

class WorkoutSessionDetailsInitial extends WorkoutSessionManipulatorState {
  @override
  List<Object> get props => [];
}

class WorkoutSessionManipulatorLoadedState
    extends WorkoutSessionManipulatorState {
  final WorkoutSession workoutSession;

  WorkoutSessionManipulatorLoadedState({required this.workoutSession});

  static WorkoutSessionManipulatorLoadedState fromState(
    WorkoutSessionManipulatorLoadedState state, {
    workoutSession,
  }) {
    return WorkoutSessionManipulatorLoadedState(
      workoutSession: workoutSession ?? state.workoutSession,
    );
  }

  @override
  List<Object?> get props => [workoutSession];
}

class WorkoutSessionManipulatorEditingState
    extends WorkoutSessionManipulatorLoadedState {
  final bool isDragging;
  final Map<int, WorkoutPhase> movedPhases;

  WorkoutSessionManipulatorEditingState(
      {required WorkoutSession workoutSession,
      required this.isDragging,
      required this.movedPhases})
      : super(workoutSession: workoutSession);

  WorkoutSessionManipulatorEditingState copyWith(
      {bool? isDraggingSession,
      WorkoutSession? workoutSession,
      Map<int, WorkoutPhase>? movedPhases}) {
    return WorkoutSessionManipulatorEditingState(
        isDragging: isDraggingSession ?? this.isDragging,
        workoutSession: workoutSession ?? this.workoutSession,
        movedPhases: movedPhases ?? this.movedPhases);
  }

  static WorkoutSessionManipulatorEditingState fromLoadedState(
      WorkoutSessionManipulatorLoadedState state,
      {WorkoutSession? workoutSession,
      bool? isDragging}) {
    return WorkoutSessionManipulatorEditingState(
        workoutSession: workoutSession ?? state.workoutSession,
        isDragging: isDragging ?? false,
        movedPhases: Map());
  }

  @override
  List<Object?> get props => [isDragging, movedPhases, ...super.props];
}

class WorkoutSessionManipulatorErrorState
    extends WorkoutSessionManipulatorEditingState {
  final String error;

  WorkoutSessionManipulatorErrorState._(this.error,
      {required WorkoutSession workoutSession,
      required bool isDragging,
      required Map<int, WorkoutPhase> movedPhases})
      : super(
            workoutSession: workoutSession,
            isDragging: isDragging,
            movedPhases: movedPhases);

  static WorkoutSessionManipulatorErrorState fromState(
      WorkoutSessionManipulatorEditingState state, String errorMessage,
      {WorkoutSession? workoutSession}) {
    return WorkoutSessionManipulatorErrorState._(errorMessage,
        workoutSession: workoutSession ?? state.workoutSession,
        isDragging: state.isDragging,
        movedPhases: state.movedPhases);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}
