import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';

part 'workout_session_manipulator_event.dart';

part 'workout_session_manipulator_state.dart';

class WorkoutSessionManipulatorBloc extends Bloc<WorkoutSessionManipulatorEvent,
    WorkoutSessionManipulatorState> {
  final WorkoutRepository _workoutRepository;

  WorkoutSessionManipulatorBloc()
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutSessionDetailsInitial()) {
    on<LoadSessionEvent>((event, emit) => _handleLoadSessionEvent(emit, event));
    on<StartWorkoutSessionEditionEvent>(
        (event, emit) => _handleStartWorkoutSessionEditionEvent(emit));
    on<SaveSessionWorkoutEditionEvent>(
        (event, emit) => _handleSaveSessionWorkoutEditionEvent(emit));
    on<MoveWorkoutPhaseEditionEvent>(
        (event, emit) => _handleMoveWorkoutPhaseEditionEvent(emit, event));
    on<DeleteWorkoutPhaseEditionEvent>(
        (event, emit) => _handleDeleteSessionWorkoutEditionEvent(emit, event));
  }

  void _handleSaveSessionWorkoutEditionEvent(Emitter emit) {
    // TODO
  }

  void _handleDeleteSessionWorkoutEditionEvent(
      Emitter emit, DeleteWorkoutPhaseEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;
      final phase = currentState.workoutSession.phases
          .firstWhereOrNull((element) => element.id == event.workputPhaseId);
      if (!currentState.deletedPhases.containsKey(event.workputPhaseId) &&
          phase != null) {
        final movedPhases =
            Map<int, WorkoutPhase>.from(currentState.movedPhases);
        movedPhases.remove(event.workputPhaseId);
        final deletedPhases =
            Map<int, WorkoutPhase>.from(currentState.deletedPhases);
        deletedPhases[event.workputPhaseId] = phase;

        emit(currentState.copyWith(
            movedPhases: movedPhases,
            orderedPhases: getOrderedPhases(currentState.workoutSession,
                movedPhases: movedPhases, deletedPhases: deletedPhases),
            deletedPhases: deletedPhases));
      }
    }
  }

  void _handleMoveWorkoutPhaseEditionEvent(
      Emitter emit, MoveWorkoutPhaseEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;

      final originalPhase = currentState.workoutSession.phases
          .firstWhereOrNull((element) => element.id == event.phase.id);
      final newMap = Map<int, WorkoutPhase>.from(currentState.movedPhases);

      // If nothing changed just skip
      if (originalPhase == null ||
          originalPhase.sequence == event.targetSequence) {
        // One thing before skipping. If the phase is dragged back to its original
        // position it can be removed from the moved map
        if (originalPhase != null &&
            currentState.movedPhases.containsKey(event.phase.id)) {
          newMap.remove(event.phase.id);
        }
      } else {
        newMap[event.phase.id!] =
            event.phase.copyWith(sequence: event.targetSequence);
      }
      emit(currentState.copyWith(
          movedPhases: newMap,
          orderedPhases: getOrderedPhases(currentState.workoutSession,
              movedPhases: newMap)));
    }
  }

  void _handleStartWorkoutSessionEditionEvent(Emitter emit) {
    if (state is! WorkoutSessionManipulatorEditingState &&
        state is WorkoutSessionManipulatorLoadedState) {
      emit(WorkoutSessionManipulatorEditingState.fromLoadedState(
        state as WorkoutSessionManipulatorLoadedState,
      ));
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
          workoutSession: session!, orderedPhases: getOrderedPhases(session!));
      emit(event.initEditMode
          ? WorkoutSessionManipulatorEditingState.fromLoadedState(state)
          : state);
    }).catchError((err) {
      print("errrrrorrr");
    });
  }

  List<WorkoutPhase> getOrderedPhases(WorkoutSession workoutSession,
      {Map<int, WorkoutPhase>? movedPhases,
      Map<int, WorkoutPhase>? deletedPhases}) {
    final ordererdPhases =
        List<WorkoutPhase>.from(workoutSession.phases, growable: true);
    if (deletedPhases != null) {
      for (final deletedId in deletedPhases.keys) {
        ordererdPhases.removeWhere((element) => element.id == deletedId);
      }
    }
    if (movedPhases != null) {
      for (final movedKv in movedPhases.entries) {
        final index =
            ordererdPhases.indexWhere((element) => element.id == movedKv.key);
        if (index >= 0) {
          ordererdPhases.removeAt(index);
          ordererdPhases.add(movedKv.value);
        }
      }
    }
    ordererdPhases.sort((a, b) => a.sequence!.compareTo(b.sequence!));
    return ordererdPhases;
  }
}
