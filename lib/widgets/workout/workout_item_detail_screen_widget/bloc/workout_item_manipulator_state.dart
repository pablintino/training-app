part of 'workout_item_manipulator_bloc.dart';

abstract class WorkoutItemManipulatorState extends Equatable {
  const WorkoutItemManipulatorState();
}

class WorkoutItemManipulatorInitialState extends WorkoutItemManipulatorState {
  @override
  List<Object> get props => [];
}

class WorkoutItemManipulatorEditingState extends WorkoutItemManipulatorState {
  final WorkoutItem workoutItem;
  final WorkoutPhase parentWorkoutPhase;
  final StringField workoutItemName;
  final StringField workoutItemModality;
  final IntegerField workoutItemRounds;
  final IntegerField workoutItemTimeCap;
  final IntegerField workoutItemWorkTime;
  final IntegerField workoutItemRestTime;
  final List<WorkoutSet> orderedSets;
  final Map<int, WorkoutSet> editedSets;

  WorkoutItemManipulatorEditingState({
    required this.workoutItem,
    required this.parentWorkoutPhase,
    required this.orderedSets,
    required this.editedSets,
    required this.workoutItemName,
    required this.workoutItemModality,
    required this.workoutItemRounds,
    required this.workoutItemTimeCap,
    required this.workoutItemWorkTime,
    required this.workoutItemRestTime,
  });

  WorkoutItemManipulatorEditingState copyWith(
      {WorkoutItem? workoutItem,
      WorkoutPhase? parentWorkoutPhase,
      List<WorkoutSet>? orderedSets,
      Map<int, WorkoutSet>? editedSets,
      StringField? workoutItemName,
      StringField? workoutItemModality,
      IntegerField? workoutItemRounds,
      IntegerField? workoutItemTimeCap,
      IntegerField? workoutItemWorkTime,
      IntegerField? workoutItemRestTime}) {
    return WorkoutItemManipulatorEditingState(
        workoutItem: workoutItem ?? this.workoutItem,
        parentWorkoutPhase: parentWorkoutPhase ?? this.parentWorkoutPhase,
        editedSets: editedSets ?? this.editedSets,
        orderedSets: orderedSets ?? this.orderedSets,
        workoutItemName: workoutItemName ?? this.workoutItemName,
        workoutItemModality: workoutItemModality ?? this.workoutItemModality,
        workoutItemRounds: workoutItemRounds ?? this.workoutItemRounds,
        workoutItemTimeCap: workoutItemTimeCap ?? this.workoutItemTimeCap,
        workoutItemWorkTime: workoutItemWorkTime ?? this.workoutItemWorkTime,
        workoutItemRestTime: workoutItemRestTime ?? this.workoutItemRestTime);
  }

  @override
  List<Object?> get props => [
        workoutItem,
        parentWorkoutPhase,
        workoutItemName,
        workoutItemModality,
        workoutItemRounds,
        workoutItemTimeCap,
        workoutItemWorkTime,
        workoutItemRestTime,
        orderedSets,
        editedSets
      ];
}

class WorkoutItemManipulatorErrorState
    extends WorkoutItemManipulatorEditingState {
  final String error;

  WorkoutItemManipulatorErrorState._(this.error,
      {required WorkoutItem workoutItem,
      required WorkoutPhase parentWorkoutPhase,
      required List<WorkoutSet> orderedSets,
      required Map<int, WorkoutSet> editedSets,
      required StringField workoutItemName,
      required StringField workoutItemModality,
      required IntegerField workoutItemRounds,
      required IntegerField workoutItemTimeCap,
      required IntegerField workoutItemWorkTime,
      required IntegerField workoutItemRestTime})
      : super(
            workoutItem: workoutItem,
            parentWorkoutPhase: parentWorkoutPhase,
            orderedSets: orderedSets,
            editedSets: editedSets,
            workoutItemName: workoutItemName,
            workoutItemModality: workoutItemModality,
            workoutItemRounds: workoutItemRounds,
            workoutItemTimeCap: workoutItemTimeCap,
            workoutItemWorkTime: workoutItemWorkTime,
            workoutItemRestTime: workoutItemRestTime);

  static WorkoutItemManipulatorErrorState fromState(
      WorkoutItemManipulatorEditingState state, String errorMessage,
      {WorkoutItem? workoutItem,
      WorkoutPhase? parentWorkoutPhase,
      List<WorkoutSet>? orderedSets,
      Map<int, WorkoutSet>? editedSets,
      StringField? workoutItemName,
      StringField? workoutItemModality,
      IntegerField? workoutItemRounds,
      IntegerField? workoutItemTimeCap,
      IntegerField? workoutItemWorkTime,
      IntegerField? workoutItemRestTime}) {
    return WorkoutItemManipulatorErrorState._(errorMessage,
        workoutItem: workoutItem ?? state.workoutItem,
        parentWorkoutPhase: parentWorkoutPhase ?? state.parentWorkoutPhase,
        orderedSets: orderedSets ?? state.orderedSets,
        editedSets: editedSets ?? state.editedSets,
        workoutItemName: workoutItemName ?? state.workoutItemName,
        workoutItemModality: workoutItemModality ?? state.workoutItemModality,
        workoutItemRounds: workoutItemRounds ?? state.workoutItemRounds,
        workoutItemTimeCap: workoutItemTimeCap ?? state.workoutItemTimeCap,
        workoutItemWorkTime: workoutItemWorkTime ?? state.workoutItemWorkTime,
        workoutItemRestTime: workoutItemRestTime ?? state.workoutItemRestTime);
  }

  @override
  List<Object?> get props => [error, ...super.props];
}
