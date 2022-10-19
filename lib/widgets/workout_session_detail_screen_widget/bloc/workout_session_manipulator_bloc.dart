import 'dart:async';

import 'package:bloc/bloc.dart';
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

  void _handleMoveWorkoutPhaseEditionEvent(
      Emitter emit, MoveWorkoutPhaseEditionEvent event) {
    if (state is WorkoutSessionManipulatorEditingState) {
      final currentState = state as WorkoutSessionManipulatorEditingState;

      if (currentState.editedPhases.containsKey(event.phase.id)) {
        final tmpPhases =
            List<WorkoutPhase>.from(currentState.orderedPhases, growable: true);
        final phase = currentState.editedPhases[event.phase.id]!;
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
          orderedPhases: getWorkoutSessionOrderedPhases(session!));
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

  static List<WorkoutPhase> getWorkoutSessionOrderedPhases(
      WorkoutSession workoutSession) {
    final ordererdPhases =
        List<WorkoutPhase>.from(workoutSession.phases, growable: true);

    ordererdPhases.sort((a, b) => a.sequence!.compareTo(b.sequence!));
    return ordererdPhases;
  }
}
