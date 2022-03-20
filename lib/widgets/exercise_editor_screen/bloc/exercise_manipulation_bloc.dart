import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/widgets/exercise_editor_screen/bloc/state_form_models.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';

part 'exercise_manipulation_event.dart';

part 'exercise_manipulation_state.dart';

class ExerciseManipulationBloc
    extends Bloc<ExerciseManipulationEvent, ExerciseManipulationState> {
  final ExerciseListBloc _exerciseListBloc;
  final ExercisesRepository _exercisesRepository;

  ExerciseManipulationBloc(this._exerciseListBloc)
      : _exercisesRepository = GetIt.instance<ExercisesRepository>(),
        super(OnGoingExerciseManipulationState.empty()) {
    on<SubmitExerciseEvent>(
        (event, emit) => _handleCreateExerciseEvent(event, emit));
    on<DescriptionInputUpdateEvent>(
        (event, emit) => _handleDescriptionInputEvent(event, emit));
    on<NameInputUpdateEvent>(
        (event, emit) => _handleNameInputEvent(event, emit));
  }

  Future<void> _handleCreateExerciseEvent(
      SubmitExerciseEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      if (!currentState.exerciseDescriptionField.valid ||
          !currentState.exerciseNameField.valid) {
        // Emmit cannot save. Validation errors

      } else {
        // TODO. The currentState.exercise! can be improved
        await _exercisesRepository
            .createExercise(currentState.exercise!)
            .then((exercise) {
          // Notify the list about the change
          _exerciseListBloc.add(ModifiedOrCreatedExerciseEvent(exercise));

          emit(ExerciseManipulationFinishedState.fromState(state,
              exercise: exercise));
        }).catchError((error, stackTrace) {
          emit(ExerciseManipulationErrorState.fromState(
              currentState, error.toString()));
        });
      }
    }
  }

  Future<void> _handleDescriptionInputEvent(
      DescriptionInputUpdateEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      await _generateValidationState(currentState,
              currentState.exerciseNameField.value, event.descriptionValue)
          .then((newState) {
        emit(newState);
      }).catchError((onError) {
        print('Errrrrorrr');
        //TODO
      });
    }
    //Else: Cannot be reached...
  }

  Future<void> _handleNameInputEvent(
      NameInputUpdateEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      await _generateValidationState(currentState, event.nameValue,
              currentState.exerciseDescriptionField.value)
          .then((newState) {
        emit(newState);
      }).catchError((onError) {
        print('Errrrrorrr');
        //TODO
      });
    }
    //Else: Cannot be reached...
  }

  Future<OnGoingExerciseManipulationState> _generateValidationState(
      OnGoingExerciseManipulationState currentState,
      String? nameInput,
      String? descriptionInput) async {
    ExerciseNameField nameField;
    if (nameInput == null || nameInput.isEmpty) {
      nameField = ExerciseNameField.invalid(
          currentState.exerciseNameField, ExerciseNameInputError.empty,
          value: nameInput);
    } else if (await _exercisesRepository.existsByName(nameInput)) {
      nameField = ExerciseNameField.invalid(
          currentState.exerciseNameField, ExerciseNameInputError.alreadyExists,
          value: nameInput);
    } else {
      nameField = ExerciseNameField.valid(currentState.exerciseNameField,
          value: nameInput);
    }
    ExerciseDescriptionField descriptionField;
    if (descriptionInput == null || descriptionInput.isEmpty) {
      descriptionField = ExerciseDescriptionField.invalid(
          currentState.exerciseDescriptionField,
          ExerciseDescriptionInputError.empty,
          value: descriptionInput);
    } else {
      descriptionField = ExerciseDescriptionField.valid(
          currentState.exerciseDescriptionField,
          value: descriptionInput);
    }

    return currentState.copyWith(
        exerciseDescriptionField: descriptionField,
        exerciseNameField: nameField,
        exercise: Exercise(name: nameInput, description: descriptionInput));
  }
}
