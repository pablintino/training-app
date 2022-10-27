import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/utils/streams.dart';

part 'workout_item_manipulator_event.dart';

part 'workout_item_manipulator_state.dart';

class WorkoutItemManipulatorBloc
    extends Bloc<WorkoutItemManipulatorEvent, WorkoutItemManipulatorState> {
  final WorkoutRepository _workoutRepository;

  WorkoutItemManipulatorBloc()
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutItemManipulatorInitialState()) {
    on<LoadItemEvent>((event, emit) => _handleLoadItemEvent(emit, event));
    on<WorkoutItemWorkTimeChanged>(
        (event, emit) => _handleWorkTimeChangedEvent(emit, event));
    on<WorkoutItemRestTimeChanged>(
        (event, emit) => _handleRestTimeChangedEvent(emit, event));
    on<WorkoutItemTimeCapChanged>(
        (event, emit) => _handleTimeCapChangedEvent(emit, event));
    on<WorkoutItemRoundsChanged>(
        (event, emit) => _handleWorkRoundsChangedEvent(emit, event));
    on<WorkoutItemNameChanged>(
        (event, emit) => _handleWorkoutItemNameChanged(emit, event),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));

    on<WorkoutItemModalityChanged>(
        (event, emit) => _handleWorkoutItemModalityChanged(emit, event),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
  }

  void _handleWorkoutItemNameChanged(
      Emitter emit, WorkoutItemNameChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      WorkoutItemManipulatorEditingState currentState =
          state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemName: _updateNameField(currentState, event.name)));
    }
  }

  void _handleWorkoutItemModalityChanged(
      Emitter emit, WorkoutItemModalityChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      final currentState = state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemModality: StringField.createValidFrom(
              currentState.workoutItemModality, event.modality)));
    }
  }

  void _handleWorkRoundsChangedEvent(
      Emitter emit, WorkoutItemRoundsChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      final currentState = state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemRounds: IntegerField.createValidFrom(
              currentState.workoutItemRounds, event.rounds)));
    }
  }

  void _handleWorkTimeChangedEvent(
      Emitter emit, WorkoutItemWorkTimeChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      final currentState = state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemWorkTime: IntegerField.createValidFrom(
              currentState.workoutItemWorkTime, event.workTimeSecs)));
    }
  }

  void _handleRestTimeChangedEvent(
      Emitter emit, WorkoutItemRestTimeChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      final currentState = state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemRestTime: IntegerField.createValidFrom(
              currentState.workoutItemRestTime, event.restTimeSecs)));
    }
  }

  void _handleTimeCapChangedEvent(
      Emitter emit, WorkoutItemTimeCapChanged event) {
    if (state is WorkoutItemManipulatorEditingState) {
      final currentState = state as WorkoutItemManipulatorEditingState;
      emit(currentState.copyWith(
          workoutItemTimeCap: IntegerField.createValidFrom(
              currentState.workoutItemTimeCap, event.timeCapSecs)));
    }
  }

  Future<void> _handleLoadItemEvent(Emitter emit, LoadItemEvent event) async {
    // On reload just grab the first page

    emit(WorkoutItemManipulatorEditingState(
      workoutItem: event.workoutItem,
      parentWorkoutPhase: event.parentWorkoutPhase,
      orderedSets: getWorkoutItemOrderedSets(event.workoutItem),
      editedSets: {for (final set in event.workoutItem.sets) set.id!: set},
      workoutItemModality: StringField(value: event.workoutItem.workModality),
      workoutItemRestTime: IntegerField(value: event.workoutItem.restTimeSecs),
      workoutItemTimeCap: IntegerField(value: event.workoutItem.timeCapSecs),
      workoutItemWorkTime: IntegerField(value: event.workoutItem.workTimeSecs),
      workoutItemRounds: IntegerField(value: event.workoutItem.rounds),
      workoutItemName: StringField(value: event.workoutItem.name),
    ));
  }

  static List<WorkoutSet> getWorkoutItemOrderedSets(WorkoutItem workoutItem) {
    final sortedSets = List<WorkoutSet>.from(workoutItem.sets, growable: true);

    sortedSets.sort((a, b) => a.sequence!.compareTo(b.sequence!));
    return sortedSets;
  }

  StringField _updateNameField(
      WorkoutItemManipulatorEditingState currentState, String? value) {
    if (value == null || value.isEmpty) {
      return StringField.createInvalidFrom(
          currentState.workoutItemName, ValidationError.empty, value);
    }

    final existingItem = currentState.parentWorkoutPhase.items
        .where((element) => element.name == value)
        .firstOrNull;

    if (existingItem?.id != null &&
        existingItem!.id != currentState.workoutItem?.id) {
      // If new the name should be unique
      return StringField.createInvalidFrom(
          currentState.workoutItemName, ValidationError.alreadyExists, value);
    }
    return StringField.createValidFrom(currentState.workoutItemName, value);
  }
}
