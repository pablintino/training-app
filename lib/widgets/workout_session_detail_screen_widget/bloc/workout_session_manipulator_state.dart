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
  final List<WorkoutPhase> orderedPhases;

  WorkoutSessionManipulatorLoadedState(
      {required this.workoutSession, required this.orderedPhases});

  static WorkoutSessionManipulatorLoadedState fromState(
      WorkoutSessionManipulatorLoadedState state,
      {workoutSession,
      orderedPhases}) {
    return WorkoutSessionManipulatorLoadedState(
      workoutSession: workoutSession ?? state.workoutSession,
      orderedPhases: orderedPhases ?? state.orderedPhases,
    );
  }

  @override
  List<Object?> get props => [workoutSession, orderedPhases];
}

class WorkoutSessionManipulatorEditingState
    extends WorkoutSessionManipulatorLoadedState {
  final bool isDragging;
  final Map<int, WorkoutPhase> movedPhases;
  final Map<int, WorkoutPhase> deletedPhases;

  WorkoutSessionManipulatorEditingState(
      {required WorkoutSession workoutSession,
      required List<WorkoutPhase> orderedPhases,
      required this.deletedPhases,
      required this.isDragging,
      required this.movedPhases})
      : super(workoutSession: workoutSession, orderedPhases: orderedPhases);

  WorkoutSessionManipulatorEditingState copyWith({
    bool? isDraggingSession,
    WorkoutSession? workoutSession,
    List<WorkoutPhase>? orderedPhases,
    Map<int, WorkoutPhase>? movedPhases,
    Map<int, WorkoutPhase>? deletedPhases,
  }) {
    return WorkoutSessionManipulatorEditingState(
        isDragging: isDraggingSession ?? this.isDragging,
        workoutSession: workoutSession ?? this.workoutSession,
        movedPhases: movedPhases ?? this.movedPhases,
        deletedPhases: deletedPhases ?? this.deletedPhases,
        orderedPhases: orderedPhases ?? this.orderedPhases);
  }

  static WorkoutSessionManipulatorEditingState fromLoadedState(
      WorkoutSessionManipulatorLoadedState state,
      {WorkoutSession? workoutSession,
      List<WorkoutPhase>? orderedPhases,
      Map<int, WorkoutPhase>? deletedPhases,
      bool? isDragging}) {
    return WorkoutSessionManipulatorEditingState(
        workoutSession: workoutSession ?? state.workoutSession,
        orderedPhases: orderedPhases ?? state.orderedPhases,
        isDragging: isDragging ?? false,
        deletedPhases: Map(),
        movedPhases: Map());
  }

  @override
  List<Object?> get props =>
      [isDragging, movedPhases, deletedPhases, ...super.props];
}

class WorkoutSessionManipulatorErrorState
    extends WorkoutSessionManipulatorEditingState {
  final String error;

  WorkoutSessionManipulatorErrorState._(this.error,
      {required WorkoutSession workoutSession,
      required List<WorkoutPhase> orderedPhases,
      required Map<int, WorkoutPhase> deletedPhases,
      required bool isDragging,
      required Map<int, WorkoutPhase> movedPhases})
      : super(
            workoutSession: workoutSession,
            orderedPhases: orderedPhases,
            deletedPhases: deletedPhases,
            isDragging: isDragging,
            movedPhases: movedPhases);

  static WorkoutSessionManipulatorErrorState fromState(
      WorkoutSessionManipulatorEditingState state, String errorMessage,
      {WorkoutSession? workoutSession,
      List<WorkoutPhase>? orderedPhases,
      Map<int, WorkoutPhase>? deletedPhases}) {
    return WorkoutSessionManipulatorErrorState._(errorMessage,
        workoutSession: workoutSession ?? state.workoutSession,
        orderedPhases: orderedPhases ?? state.orderedPhases,
        deletedPhases: deletedPhases ?? state.deletedPhases,
        isDragging: state.isDragging,
        movedPhases: state.movedPhases);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}
