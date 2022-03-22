import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/utils/streams.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';

part 'exercise_manipulation_event.dart';

part 'exercise_manipulation_state.dart';

class _ExerciseFormFields {
  final StringField name;
  final StringField description;

  _ExerciseFormFields(this.name, this.description);
}

class ExerciseManipulationBloc
    extends Bloc<ExerciseManipulationEvent, ExerciseManipulationState> {
  final ExerciseListBloc _exerciseListBloc;
  final ExercisesRepository _exercisesRepository;

  ExerciseManipulationBloc(this._exerciseListBloc)
      : _exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(OnGoingExerciseManipulationState.empty()) {
    on<SubmitExerciseEvent>(
        (event, emit) => _handleCreateExerciseEvent(event, emit));
    on<InitializeUpdateEvent>(
        (event, emit) => _handleInitializeUpdateEvent(event, emit));
    on<DescriptionInputUpdateEvent>(
        (event, emit) => _handleDescriptionInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
    on<NameInputUpdateEvent>(
        (event, emit) => _handleNameInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
  }

  void _handleInitializeUpdateEvent(InitializeUpdateEvent event, Emitter emit) {
    emit(OnGoingExerciseManipulationState.pure(
        event.exercise.name, event.exercise.description,
        initialExercise: event.exercise));
  }

  Future<void> _handleCreateExerciseEvent(
      SubmitExerciseEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;

      await _validate(currentState).then((validationResult) async {
        if (!validationResult.name.valid ||
            !validationResult.description.valid) {
          // Emmit cannot save. Validation errors
          emit(currentState.copyWith(
              exerciseName: validationResult.name,
              exerciseDescription: validationResult.description));
        } else {
          await __performSave(validationResult).then((exercise) {
            // Notify the list about the change
            _exerciseListBloc.add(ModifiedOrCreatedExerciseEvent(exercise));

            emit(ExerciseManipulationFinishedState.fromState(state,
                exercise: exercise));
          }).catchError((error, stackTrace) {
            emit(ExerciseManipulationErrorState.fromState(
                currentState, error.toString()));
          });
        }
      }).catchError((error, stackTrace) {
        emit(ExerciseManipulationErrorState.fromState(
            currentState, error.toString()));
      });
    }
  }

  Future<Exercise> __performSave(_ExerciseFormFields validationResult) async {
    // If initial exercise is null we are creating a new exercise
    if (state.initialExercise?.id == null) {
      return await _exercisesRepository.createExercise(Exercise(
          name: validationResult.name.value,
          description: validationResult.description.value));
    }
    return await _exercisesRepository.updateExercise(Exercise(
        id: state.initialExercise?.id!,
        name: validationResult.name.value,
        description: validationResult.description.value));
  }

  void _handleDescriptionInputEvent(
      DescriptionInputUpdateEvent event, Emitter emit) {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      emit(currentState.copyWith(
          exerciseDescription: _updateDescriptionField(
              currentState.exerciseDescription, event.descriptionValue)));
    }
    //Else: Cannot be reached...
  }

  Future<void> _handleNameInputEvent(
      NameInputUpdateEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      await _updateNameField(currentState, event.nameValue).then((fieldState) {
        emit(currentState.copyWith(exerciseName: fieldState));
      }).catchError((err) {
        // Probably async validation gone wrong
        emit(ExerciseManipulationErrorState.fromState(
            currentState, err.toString()));
      });
    }
    //Else: Cannot be reached...
  }

  Future<_ExerciseFormFields> _validate(
      OnGoingExerciseManipulationState currentState) async {
    final descriptionField = _updateDescriptionField(
        currentState.exerciseDescription,
        currentState.exerciseDescription.value);
    final nameField =
        await _updateNameField(currentState, currentState.exerciseName.value);
    return _ExerciseFormFields(nameField, descriptionField);
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
      OnGoingExerciseManipulationState currentState, String? value) async {
    StringField nameField;
    if (value == null || value.isEmpty) {
      return StringField.createInvalidFrom(
          currentState.exerciseName, ValidationError.empty,
          value: value);
    }
    final exercise = await _exercisesRepository.getByName(value);
    if (exercise != null &&
        (currentState.initialExercise?.id == null ||
            exercise.id != currentState.initialExercise?.id)) {
      // If new the name should be unique
      return StringField.createInvalidFrom(
          currentState.exerciseName, ValidationError.alreadyExists,
          value: value);
    }
    return StringField.createValidFrom(currentState.exerciseName, value: value);
  }
}
