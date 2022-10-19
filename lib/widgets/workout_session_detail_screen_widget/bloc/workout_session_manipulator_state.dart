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
  final Map<int, WorkoutPhase> editedPhases;

  WorkoutSessionManipulatorEditingState(
      {required WorkoutSession workoutSession,
      required List<WorkoutPhase> orderedPhases,
      required this.isDragging,
      required this.editedPhases})
      : super(workoutSession: workoutSession, orderedPhases: orderedPhases);

  WorkoutSessionManipulatorEditingState copyWith({
    bool? isDraggingSession,
    WorkoutSession? workoutSession,
    List<WorkoutPhase>? orderedPhases,
    Map<int, WorkoutPhase>? editedPhases,
  }) {
    return WorkoutSessionManipulatorEditingState(
        isDragging: isDraggingSession ?? this.isDragging,
        workoutSession: workoutSession ?? this.workoutSession,
        editedPhases: editedPhases ?? this.editedPhases,
        orderedPhases: orderedPhases ?? this.orderedPhases);
  }

  static WorkoutSessionManipulatorEditingState fromLoadedState(
      WorkoutSessionManipulatorLoadedState state,
      {WorkoutSession? workoutSession,
      List<WorkoutPhase>? orderedPhases,
      Map<int, WorkoutPhase>? editedPhases,
      bool? isDragging}) {
    return WorkoutSessionManipulatorEditingState(
        workoutSession: workoutSession ?? state.workoutSession,
        orderedPhases: orderedPhases ?? state.orderedPhases,
        isDragging: isDragging ?? false,
        editedPhases: editedPhases ?? Map());
  }

  @override
  List<Object?> get props => [isDragging, editedPhases, ...super.props];
}

class WorkoutSessionManipulatorErrorState
    extends WorkoutSessionManipulatorEditingState {
  final String error;

  WorkoutSessionManipulatorErrorState._(this.error,
      {required WorkoutSession workoutSession,
      required List<WorkoutPhase> orderedPhases,
      required bool isDragging,
      required Map<int, WorkoutPhase> editedPhases})
      : super(
            workoutSession: workoutSession,
            orderedPhases: orderedPhases,
            isDragging: isDragging,
            editedPhases: editedPhases);

  static WorkoutSessionManipulatorErrorState fromState(
      WorkoutSessionManipulatorEditingState state, String errorMessage,
      {WorkoutSession? workoutSession,
      List<WorkoutPhase>? orderedPhases,
      Map<int, WorkoutPhase>? editedPhases}) {
    return WorkoutSessionManipulatorErrorState._(errorMessage,
        workoutSession: workoutSession ?? state.workoutSession,
        orderedPhases: orderedPhases ?? state.orderedPhases,
        editedPhases: editedPhases ?? state.editedPhases,
        isDragging: state.isDragging);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}
