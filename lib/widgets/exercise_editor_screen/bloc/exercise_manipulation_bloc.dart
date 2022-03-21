import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/utils/streams.dart';
import 'package:training_app/widgets/exercise_editor_screen/bloc/state_form_models.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';
import 'package:tuple/tuple.dart';

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
        (event, emit) => _handleDescriptionInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
    on<NameInputUpdateEvent>(
        (event, emit) => _handleNameInputEvent(event, emit),
        transformer:
            DebounceTransformer.debounce(const Duration(milliseconds: 250)));
  }

  Future<void> _handleCreateExerciseEvent(
      SubmitExerciseEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;

      await _validate(currentState).then((validationResult) async {
        if (!validationResult.item1.valid || !validationResult.item2.valid) {
          // Emmit cannot save. Validation errors
          emit(currentState.copyWith(
              exerciseNameField: validationResult.item1,
              exerciseDescriptionField: validationResult.item2));
        } else {
          await _exercisesRepository
              .createExercise(Exercise(
                  name: validationResult.item1.value,
                  description: validationResult.item2.value))
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
      }).catchError((error, stackTrace) {
        emit(ExerciseManipulationErrorState.fromState(
            currentState, error.toString()));
      });
    }
  }

  void _handleDescriptionInputEvent(
      DescriptionInputUpdateEvent event, Emitter emit) {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      emit(currentState.copyWith(
          exerciseDescriptionField: _updateDescriptionField(
              currentState.exerciseDescriptionField, event.descriptionValue)));
    }
    //Else: Cannot be reached...
  }

  Future<void> _handleNameInputEvent(
      NameInputUpdateEvent event, Emitter emit) async {
    if (state is OnGoingExerciseManipulationState) {
      OnGoingExerciseManipulationState currentState =
          state as OnGoingExerciseManipulationState;
      await _updateNameField(currentState.exerciseNameField, event.nameValue)
          .then((fieldState) {
        emit(currentState.copyWith(exerciseNameField: fieldState));
      }).catchError((onError) {
        print('Errrrrorrr');
        //TODO
      });
    }
    //Else: Cannot be reached...
  }

  // TODO Temporal approach until map based fields
  Future<Tuple2<ExerciseNameField, ExerciseDescriptionField>> _validate(
      OnGoingExerciseManipulationState currentState) async {
    final descriptionField = _updateDescriptionField(
        currentState.exerciseDescriptionField,
        currentState.exerciseDescriptionField.value);
    final nameField = await _updateNameField(
        currentState.exerciseNameField, currentState.exerciseNameField.value);
    return Tuple2(nameField, descriptionField);
  }

  ExerciseDescriptionField _updateDescriptionField(
    ExerciseDescriptionField currentState,
    String? value,
  ) {
    ExerciseDescriptionField descriptionField;
    if (value == null || value.isEmpty) {
      descriptionField = ExerciseDescriptionField.createInvalidFrom(
          currentState, ExerciseDescriptionInputError.empty,
          value: value);
    } else {
      descriptionField =
          ExerciseDescriptionField.createValidFrom(currentState, value: value);
    }

    return descriptionField;
  }

  Future<ExerciseNameField> _updateNameField(
      ExerciseNameField currentState, String? value) async {
    ExerciseNameField nameField;
    if (value == null || value.isEmpty) {
      nameField = ExerciseNameField.createInvalidFrom(
          currentState, ExerciseNameInputError.empty,
          value: value);
    } else if (await _exercisesRepository.existsByName(value)) {
      nameField = ExerciseNameField.createInvalidFrom(
          currentState, ExerciseNameInputError.alreadyExists,
          value: value);
    } else {
      nameField = ExerciseNameField.createValidFrom(currentState, value: value);
    }
    return nameField;
  }
}
