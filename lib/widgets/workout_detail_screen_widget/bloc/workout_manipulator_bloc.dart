import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/repositories/workouts_repository.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/utils/streams.dart';
import 'package:training_app/widgets/workout_list_widget/bloc/workout_list_bloc.dart';

part 'workout_manipulator_event.dart';

part 'workout_manipulator_state.dart';

class _WorkoutFormFields {
  final StringField name;
  final StringField description;

  _WorkoutFormFields(this.name, this.description);
}

class WorkoutManipulatorBloc
    extends Bloc<WorkoutManipulatorEvent, WorkoutManipulatorState> {
  final WorkoutRepository _workoutRepository;
  final WorkoutListBloc workoutListBloc;

  WorkoutManipulatorBloc(this.workoutListBloc)
      : _workoutRepository = GetIt.instance<WorkoutRepository>(),
        super(WorkoutManipulatorInitialState()) {
    on<LoadWorkoutEvent>((event, emit) => _handleLoadWorkoutEvent(emit, event));
    on<SetSessionDraggingEvent>(
        (event, emit) => _handleSessionDraggingEvent(emit, event));
    on<StartWorkoutEditionEvent>(
        (event, emit) => _handleStartWorkoutEditionEvent(emit));
    on<SaveWorkoutEditionEvent>(
        (event, emit) => _handleSaveWorkoutEditionEvent(emit));
    on<DragSessionWorkoutEditionEvent>(
        (event, emit) => _handleDragSessionWorkoutEditionEvent(emit, event));
    on<DescriptionInputUpdateEvent>(
        (event, emit) => _handleDescriptionInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
    on<NameInputUpdateEvent>(
        (event, emit) => _handleNameInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
  }

  Future<void> _handleLoadWorkoutEvent(
      Emitter emit, LoadWorkoutEvent event) async {
    // On reload just grab the first page

    await _workoutRepository
        .getWorkout(event.workoutId, fat: true)
        .then((workout) {
      //TODO Check when workout is null
      emit(WorkoutManipulatorLoadedState(workout: workout!));
    }).catchError((err) {
      print("errrrrorrr");
    });
  }

  Future<void> _handleDragSessionWorkoutEditionEvent(
      Emitter emit, DragSessionWorkoutEditionEvent event) async {
    if (state is WorkoutManipulatorEditingState) {
      final currentState = state as WorkoutManipulatorEditingState;

      final originalSession = currentState.workout.sessions
          .firstWhereOrNull((element) => element.id == event.session.id);
      final newMap = Map<int, WorkoutSession>.from(currentState.movedSessions);

      // If nothing changed just skip
      if (originalSession == null ||
          (originalSession.weekDay == event.targetDay &&
              originalSession.week == event.targetWeek)) {
        // One thing before skipping. If the session is dragged back to its original
        // position it can be removed from the moved map
        if (originalSession != null &&
            currentState.movedSessions.containsKey(event.session.id)) {
          newMap.remove(event.session.id);
        }
      } else {
        newMap[event.session.id!] = WorkoutSession(
            id: event.session.id,
            phases: event.session.phases,
            week: event.targetWeek,
            weekDay: event.targetDay);
      }
      emit(currentState.copyWith(movedSessions: newMap));
    }
  }

  Future<void> _handleSessionDraggingEvent(
      Emitter emit, SetSessionDraggingEvent event) async {
    if (state is WorkoutManipulatorEditingState) {
      emit((state as WorkoutManipulatorEditingState)
          .copyWith(isDraggingSession: event.isDragging));
    }
  }

  void _handleStartWorkoutEditionEvent(Emitter emit) {
    if (state is! WorkoutManipulatorEditingState &&
        state is WorkoutManipulatorLoadedState) {
      emit(WorkoutManipulatorEditingState.fromLoadedState(
        state as WorkoutManipulatorLoadedState,
      ));
    }
  }

  Future<void> _handleSaveWorkoutEditionEvent(Emitter emit) async {
    if (state is WorkoutManipulatorEditingState) {
      final currentState = state as WorkoutManipulatorEditingState;

      // If form is untouched just skip all logic
      if (!currentState.workoutName.dirty &&
          !currentState.workoutDescription.dirty &&
          currentState.movedSessions.length == 0) {
        emit(WorkoutManipulatorLoadedState.fromState(currentState));
        return;
      }

      await _validate(currentState).then((validationResult) async {
        if (!validationResult.name.valid ||
            !validationResult.description.valid) {
          // Emmit cannot save. Validation errors
          emit(currentState.copyWith(
              workoutName: validationResult.name,
              workoutDescription: validationResult.description));
        } else {
          await __performSave(validationResult, currentState).then((workout) {
            emit(WorkoutManipulatorLoadedState.fromState(currentState,
                workout: workout));
            workoutListBloc.add(ModifiedOrCreatedWorkoutEvent(workout));
          }).catchError((error, stackTrace) {
            emit(WorkoutManipulatorErrorState.fromState(
                currentState, error.toString()));
          });
        }
      }).catchError((error, stackTrace) {
        emit(WorkoutManipulatorErrorState.fromState(
            currentState, error.toString()));
      });
    }
  }

  Future<Workout> __performSave(_WorkoutFormFields validationResult,
      WorkoutManipulatorEditingState currentState) async {
    // If initial workout is null we are creating a new exercise
    if (currentState?.workout.id == null) {
      //TODO Pending creation logic
    }
    return _workoutRepository
        .updateWorkout(Workout(
            id: currentState.workout?.id!,
            name: validationResult.name.value,
            description: validationResult.description.value))
        .then((value) async {
      for (final modifiedSession in currentState.movedSessions.entries) {
        await _workoutRepository.updateWorkoutSession(WorkoutSession(
            id: modifiedSession.value.id,
            week: modifiedSession.value.week,
            weekDay: modifiedSession.value.weekDay));
      }
      return _workoutRepository.getWorkout(value.id!, fat: true);
    })
        // Force ! cast as it should exist
        .then((value) => value!);
  }

  Future<_WorkoutFormFields> _validate(
      WorkoutManipulatorEditingState currentState) async {
    final descriptionField = _updateDescriptionField(
        currentState.workoutName, currentState.workoutDescription.value);
    final nameField =
        await _updateNameField(currentState, currentState.workoutName.value);
    return _WorkoutFormFields(nameField, descriptionField);
  }

  void _handleDescriptionInputEvent(
      DescriptionInputUpdateEvent event, Emitter emit) {
    if (state is WorkoutManipulatorEditingState) {
      WorkoutManipulatorEditingState currentState =
          state as WorkoutManipulatorEditingState;
      emit(currentState.copyWith(
          workoutDescription: _updateDescriptionField(
              currentState.workoutDescription, event.descriptionValue)));
    }
    //Else: Cannot be reached...
  }

  Future<void> _handleNameInputEvent(
      NameInputUpdateEvent event, Emitter emit) async {
    if (state is WorkoutManipulatorEditingState) {
      WorkoutManipulatorEditingState currentState =
          state as WorkoutManipulatorEditingState;
      await _updateNameField(currentState, event.nameValue).then((fieldState) {
        emit(currentState.copyWith(workoutName: fieldState));
      }).catchError((err) {
        // Probably async validation gone wrong
        emit(WorkoutManipulatorErrorState.fromState(
            currentState, err.toString()));
      });
    }
    //Else: Cannot be reached...
  }

  StringField _updateDescriptionField(
    StringField currentState,
    String? value,
  ) {
    StringField descriptionField;
    if (value == null || value.isEmpty) {
      descriptionField = StringField.createInvalidFrom(
          currentState, ValidationError.empty,
          value: value);
    } else {
      descriptionField =
          StringField.createValidFrom(currentState, value: value);
    }

    return descriptionField;
  }

  Future<StringField> _updateNameField(
      WorkoutManipulatorEditingState currentState, String? value) async {
    if (value == null || value.isEmpty) {
      return StringField.createInvalidFrom(
          currentState.workoutName, ValidationError.empty,
          value: value);
    }
    final workout = await _workoutRepository.getByName(value);
    if (workout != null &&
        (currentState.workout?.id == null ||
            workout.id != currentState.workout?.id)) {
      // If new the name should be unique
      return StringField.createInvalidFrom(
          currentState.workoutName, ValidationError.alreadyExists,
          value: value);
    }
    return StringField.createValidFrom(currentState.workoutName, value: value);
  }
}
