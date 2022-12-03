import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';

part 'workout_session_manipulator_event.dart';

part 'workout_session_manipulator_state.dart';

class WorkoutSessionManipulatorBloc extends Bloc<WorkoutSessionManipulatorEvent,
    WorkoutSessionManipulatorState> {
  final WorkoutRepository _workoutRepository;
  final WorkoutGlobalEditingBloc workoutGlobalEditingBloc;
  late StreamSubscription<WorkoutGlobalEditingState>
      workoutGlobalEditingBlocSubscription;

  WorkoutSessionManipulatorBloc(this.workoutGlobalEditingBloc)
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutSessionDetailsInitial()) {
    // Register to global editing bloc changes
    workoutGlobalEditingBlocSubscription = workoutGlobalEditingBloc.stream
        .listen(_onWorkoutGlobalEditingBlocStateChange);

    //Register events
    on<LoadSessionEvent>((event, emit) => _handleLoadSessionEvent(emit, event));
    on<StartWorkoutSessionEditionEvent>(
        (event, emit) => _handleStartWorkoutSessionEditionEvent(emit));
    on<SaveSessionWorkoutEditionEvent>(
        (event, emit) => _handleSaveSessionWorkoutEditionEvent(emit));
    on<MoveWorkoutPhaseEditionEvent>(
        (event, emit) => _handleMoveWorkoutPhaseEditionEvent(emit, event));
    on<DeleteWorkoutPhaseEditionEvent>(
        (event, emit) => _handleDeleteSessionWorkoutEditionEvent(emit, event));
    on<MoveWorkoutItemEditionEvent>(
        (event, emit) => _handleMoveWorkoutItemEditionEvent(emit, event));
  }

  void _onWorkoutGlobalEditingBlocStateChange(
      WorkoutGlobalEditingState state) {}

  void _handleSaveSessionWorkoutEditionEvent(Emitter emit) {
    // TODO
  }

  void _handleDeleteSessionWorkoutEditionEvent(
      Emitter emit, DeleteWorkoutPhaseEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;

      if (currentState.editedPhases.containsKey(event.workputPhaseId)) {
        final editedPhasesMap = Map<int, WorkoutPhase>();
        final orderedPhases = List<WorkoutPhase>.empty(growable: true);

        var sequential = 0;
        for (final sourcePhase in currentState.orderedPhases) {
          if (sourcePhase.id != event.workputPhaseId) {
            final editedPhase = currentState.editedPhases[sourcePhase.id]!
                .copyWith(sequence: sequential);
            editedPhasesMap[editedPhase.id!] = editedPhase;
            orderedPhases.add(editedPhase);
            sequential++;
          }
        }

        emit(currentState.copyWith(
            editedPhases: editedPhasesMap, orderedPhases: orderedPhases));
      }
    }
  }

  void _handleMoveWorkoutItemEditionEvent(
      Emitter emit, MoveWorkoutItemEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;

      if (currentState.editedPhases.containsKey(event.parentPhaseId)) {
        final parentPhase = currentState.editedPhases[event.parentPhaseId]!;
        final tmpItems =
            List<WorkoutItem>.from(parentPhase.items, growable: true);
        final originalItem = parentPhase.items
            .firstWhereOrNull((element) => element.id == event.workoutItemId);
        if (originalItem != null) {
          tmpItems.removeWhere((element) => element.id == originalItem.id);
          tmpItems.insert(event.targetSequence, originalItem);
          var sequence = 0;
          final orderedItems = List<WorkoutItem>.empty(growable: true);
          for (final sourceItem in tmpItems) {
            orderedItems.add(sourceItem.copyWith(sequence: sequence));
            sequence++;
          }

          final editedPhasesMap =
              Map<int, WorkoutPhase>.from(currentState.editedPhases);
          editedPhasesMap[event.parentPhaseId] =
              parentPhase.copyWith(items: orderedItems);
          emit(currentState.copyWith(
              editedPhases: editedPhasesMap,
              orderedPhases: getWorkoutOrderedPhases(editedPhasesMap.values)));
        }
      }
    }
  }

  void _handleMoveWorkoutPhaseEditionEvent(
      Emitter emit, MoveWorkoutPhaseEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;

      if (currentState.editedPhases.containsKey(event.phaseId)) {
        final tmpPhases =
            List<WorkoutPhase>.from(currentState.orderedPhases, growable: true);
        final phase = currentState.editedPhases[event.phaseId]!;
        tmpPhases.removeWhere((element) => element.id == phase.id);
        tmpPhases.insert(event.targetSequence, phase);
        var sequence = 0;
        final editedPhasesMap = Map<int, WorkoutPhase>();
        final orderedPhases = List<WorkoutPhase>.empty(growable: true);
        for (final sourcePhase in tmpPhases) {
          final editedPhase = sourcePhase.copyWith(sequence: sequence);
          editedPhasesMap[editedPhase.id!] = editedPhase;
          orderedPhases.add(editedPhase);
          sequence++;
        }

        emit(currentState.copyWith(
            editedPhases: editedPhasesMap, orderedPhases: orderedPhases));
      }
    }
  }

  void _handleStartWorkoutSessionEditionEvent(Emitter emit) {
    if (state is! WorkoutSessionManipulatorEditingState &&
        state is WorkoutSessionManipulatorLoadedState) {
      final currentState = state as WorkoutSessionManipulatorLoadedState;
      emit(WorkoutSessionManipulatorEditingState.fromLoadedState(
          state as WorkoutSessionManipulatorLoadedState,
          editedPhases: {
            for (var phase in currentState.workoutSession.phases)
              phase.id!: phase
          }));
    }
  }

  Future<void> _handleLoadSessionEvent(
      Emitter emit, LoadSessionEvent event) async {
    // On reload just grab the first page

    await _workoutRepository
        .getWorkoutSession(event.sessionId, fat: true)
        .then((session) {
      //TODO Control what to do with null sessions (not found)
      final state = WorkoutSessionManipulatorLoadedState(
          workoutSession: session!,
          orderedPhases: getWorkoutOrderedPhases(session.phases));
      emit(event.initEditMode
          ? WorkoutSessionManipulatorEditingState.fromLoadedState(state,
              editedPhases: {
                  for (var phase in state.workoutSession.phases)
                    phase.id!: phase
                })
          : state);
    }).catchError((err) {
      print("errrrrorrr");
    });
  }

  static List<WorkoutPhase> getWorkoutOrderedPhases(
      Iterable<WorkoutPhase> workoutPhases) {
    final orderedPhases =
        List<WorkoutPhase>.from(workoutPhases, growable: true);

    orderedPhases.sort((a, b) => a.sequence!.compareTo(b.sequence!));
    return orderedPhases;
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    workoutGlobalEditingBlocSubscription.cancel();
    return super.close();
  }
}
